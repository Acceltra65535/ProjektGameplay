# res://scripts/enemies/enemy_raider_AK47.gd
extends CharacterBody2D
class_name EnemyRaider_AK47

# State enum - added SHOOT_NEAR and SHOOT_FAR for different shooting modes
enum State { IDLE, PATROL, CHASE, ATTACK, SHOOT_NEAR, SHOOT_FAR, RECHARGE, COOLDOWN, HURT, DEATH, RETURNING }

# Behavior type enum
enum BehaviorType { GUARD, PATROL }

# Export variables - General
@export_group("General")
@export var behavior_type: BehaviorType = BehaviorType.GUARD
@export var move_speed: float = 150.0
@export var max_health: int = 50
@export var sprite_left_offset: float = 27.33  # Sprite offset when facing left

# Export variables - Combat
@export_group("Combat")
@export var attack_damage: int = 10
@export var bullet_damage: float = 15.0
@export var knockback_force: float = 200.0
@export var bullet_scene: PackedScene

# Export variables - AK47 specific
@export_group("AK47 Settings")
@export var magazine_size: int = 30               # Total bullets before reload
@export var near_shoot_range: float = 300.0       # Distance threshold for near/far shooting
@export var far_shoot_cooldown: float = 2.0       # Cooldown between far shots

# Export variables - Guard behavior
@export_group("Guard Behavior")
@export var guard_chase_distance: float = 100.0   # Max distance guard will chase from home
@export var melee_stop_distance: float = 40.0     # Stop moving when this close for melee

# Export variables - Patrol behavior
@export_group("Patrol Behavior")
@export var patrol_speed: float = 80.0            # Speed when patrolling
@export var patrol_range: float = 200.0           # Distance to patrol left/right from home
@export var patrol_wait_time: float = 1.5         # Time to wait at patrol endpoints
@export var patrol_chase_distance: float = 300.0  # Max distance patrol will chase from home
@export var shoot_range: float = 200.0            # Range to start shooting

# Node references
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var shoot_point: Marker2D = $ShootPoint
@onready var shoot_point_2: Marker2D = $ShootPoint2  # For near shooting
@onready var hurtbox: Area2D = $Hurtbox
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Preload audio resources
var near_shoot_sounds: Array[AudioStream] = []
var far_shoot_sounds: Array[AudioStream] = []
var reload_sound: AudioStream

# Directional node original offsets (local positions)
var shoot_point_original_offset: Vector2 = Vector2.ZERO
var shoot_point_2_original_offset: Vector2 = Vector2.ZERO  # For near shooting
var attack_area_original_offset: Vector2 = Vector2.ZERO
var hurtbox_original_offset: Vector2 = Vector2.ZERO
var sprite_original_offset: Vector2 = Vector2.ZERO
var directional_offsets_initialized: bool = false

# State variables
var current_state: State = State.IDLE
var health: int
var target: Node2D = null
var facing_direction: int = -1  # -1 left, 1 right

var is_frozen: bool = false

# Home position (spawn point) for patrol/return behavior
var home_position: Vector2 = Vector2.ZERO

# Patrol variables
var patrol_direction: int = 1           # 1 = right, -1 = left
var patrol_wait_timer: float = 0.0      # Timer for waiting at patrol endpoints
var is_waiting_at_endpoint: bool = false

# AK47 specific variables
var current_ammo: int = 30              # Current bullets in magazine
var far_shoot_timer: float = 0.0        # Timer for far shooting cooldown


func _ready() -> void:
	health = max_health
	current_ammo = magazine_size
	attack_cooldown.wait_time = far_shoot_cooldown
	attack_cooldown.one_shot = true

	# Store spawn position as home for patrol/return behavior
	home_position = global_position

	# Load audio resources
	_load_audio_resources()

	# Configure collision layers: enemy on layer 2, no collision with layer 1 (player)
	# This allows bullets (Area2D) to hit enemies without physical collision with player
	set_collision_layer_value(1, false)  # Remove from layer 1 (player layer)
	set_collision_layer_value(2, true)   # Add to layer 2 (enemy layer)
	set_collision_mask_value(1, false)   # Don't collide with layer 1 (player)
	set_collision_mask_value(2, false)   # Don't collide with other enemies

	# Connect signals
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_cooldown.timeout.connect(_on_attack_cooldown_timeout)
	animated_sprite.animation_finished.connect(_on_animation_finished)

	# Cache original local offsets for directional nodes
	if not directional_offsets_initialized:
		if shoot_point:
			shoot_point_original_offset = shoot_point.position
		if shoot_point_2:
			shoot_point_2_original_offset = shoot_point_2.position
		if attack_area:
			attack_area_original_offset = attack_area.position
		if hurtbox:
			hurtbox_original_offset = hurtbox.position

		sprite_original_offset = animated_sprite.position

		directional_offsets_initialized = true
		_update_directional_offsets()

	# Start in appropriate initial state based on behavior type
	if behavior_type == BehaviorType.PATROL:
		_change_state(State.PATROL)
	else:
		animated_sprite.play("idle")


func _load_audio_resources() -> void:
	# Load near shoot sounds (double shot)
	near_shoot_sounds.append(load("res://audio/Prepared SFX Library/AK-47/ak47_naer_double.wav"))
	near_shoot_sounds.append(load("res://audio/Prepared SFX Library/AK-47/ak47_near_double2.wav"))
	near_shoot_sounds.append(load("res://audio/Prepared SFX Library/AK-47/ak47_near_double3.wav"))
	near_shoot_sounds.append(load("res://audio/Prepared SFX Library/AK-47/ak47_near_double4.wav"))

	# Load far shoot sounds (single shot)
	far_shoot_sounds.append(load("res://audio/Prepared SFX Library/AK-47/ak47_far.wav"))
	far_shoot_sounds.append(load("res://audio/Prepared SFX Library/AK-47/ak47_far2.wav"))
	far_shoot_sounds.append(load("res://audio/Prepared SFX Library/AK-47/ak47_far3.wav"))
	far_shoot_sounds.append(load("res://audio/Prepared SFX Library/AK-47/ak47_far4.wav"))

	# Load reload sound
	reload_sound = load("res://audio/Prepared SFX Library/AK-47/AK Reload Full WAV.wav")


func set_frozen(value: bool) -> void:
	is_frozen = value
	if is_frozen:
		# Stop horizontal movement immediately when frozen
		velocity.x = 0.0


func _physics_process(delta: float) -> void:
	if is_frozen:
		# Still apply gravity so the player can land nicely,
		# but ignore input and commands
		move_and_slide()
		return

	match current_state:
		State.IDLE:
			_state_idle()
		State.PATROL:
			_state_patrol(delta)
		State.CHASE:
			_state_chase()
		State.ATTACK:
			_state_attack()
		State.SHOOT_NEAR:
			_state_shoot_near()
		State.SHOOT_FAR:
			_state_shoot_far()
		State.RECHARGE:
			_state_recharge()
		State.COOLDOWN:
			_state_cooldown(delta)
		State.HURT:
			_state_hurt()
		State.DEATH:
			_state_death()
		State.RETURNING:
			_state_returning()

	move_and_slide()


func _update_directional_offsets() -> void:
	# Update directional nodes (shoot point, attack area, hurtbox) based on current flip state.
	# Since the sprite is now centered, we just mirror the offset positions.
	if not directional_offsets_initialized:
		return

	var flip_sign := 1.0
	var sprite_x_offset := 0.0

	if animated_sprite.flip_h:
		# When facing left, mirror on X axis and apply left offset
		flip_sign = -1.0
		sprite_x_offset = -sprite_left_offset

	# Update sprite position with left offset when facing left
	if animated_sprite:
		animated_sprite.position = Vector2(
			sprite_original_offset.x + sprite_x_offset,
			sprite_original_offset.y
		)

	if shoot_point:
		shoot_point.position = Vector2(
			shoot_point_original_offset.x * flip_sign,
			shoot_point_original_offset.y
		)

	if shoot_point_2:
		shoot_point_2.position = Vector2(
			shoot_point_2_original_offset.x * flip_sign,
			shoot_point_2_original_offset.y
		)

	if attack_area:
		attack_area.position = Vector2(
			attack_area_original_offset.x * flip_sign,
			attack_area_original_offset.y
		)

	if hurtbox:
		hurtbox.position = Vector2(
			hurtbox_original_offset.x * flip_sign,
			hurtbox_original_offset.y
		)
		

# State logic
func _state_idle() -> void:
	velocity = Vector2.ZERO
	if animated_sprite.animation != "idle":
		animated_sprite.play("idle")

	# For patrol type, check if we should start patrolling again
	if behavior_type == BehaviorType.PATROL and not is_instance_valid(target):
		_change_state(State.PATROL)


func _state_patrol(delta: float) -> void:
	# Patrol behavior: walk left/right within patrol_range from home_position

	# If we have a target, switch to chase immediately
	if is_instance_valid(target):
		_change_state(State.CHASE)
		return

	if is_waiting_at_endpoint:
		# Wait at endpoint before turning around
		velocity.x = 0.0
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")
		patrol_wait_timer -= delta
		if patrol_wait_timer <= 0:
			is_waiting_at_endpoint = false
			patrol_direction *= -1  # Reverse direction
		return

	# Calculate patrol boundaries
	var left_bound: float = home_position.x - patrol_range
	var right_bound: float = home_position.x + patrol_range

	# Check if reached patrol boundary first
	if patrol_direction > 0 and global_position.x >= right_bound:
		is_waiting_at_endpoint = true
		patrol_wait_timer = patrol_wait_time
		velocity.x = 0.0
		animated_sprite.play("idle")
		return
	elif patrol_direction < 0 and global_position.x <= left_bound:
		is_waiting_at_endpoint = true
		patrol_wait_timer = patrol_wait_time
		velocity.x = 0.0
		animated_sprite.play("idle")
		return

	# Move in patrol direction
	velocity.x = patrol_direction * patrol_speed
	facing_direction = patrol_direction
	animated_sprite.flip_h = (patrol_direction < 0)
	_update_directional_offsets()

	if animated_sprite.animation != "run":
		animated_sprite.play("run")


func _state_chase() -> void:
	# DEBUG: Print chase state info
	print("[AK47] _state_chase called. target valid: ", is_instance_valid(target))

	if not is_instance_valid(target):
		_return_to_home_or_idle()
		return

	var distance_to_target: float = abs(target.global_position.x - global_position.x)
	print("[AK47] Distance to target: ", distance_to_target, " shoot_range: ", shoot_range, " near_shoot_range: ", near_shoot_range)
	var distance_from_home: float = abs(global_position.x - home_position.x)

	# Determine max chase distance based on behavior type
	var max_chase: float = guard_chase_distance if behavior_type == BehaviorType.GUARD else patrol_chase_distance

	# Check if we've chased too far from home
	if distance_from_home > max_chase:
		target = null
		_change_state(State.RETURNING)
		return

	# Check if we need to reload first
	if current_ammo <= 0:
		_change_state(State.RECHARGE)
		return

	# Face the target
	var direction: int = sign(target.global_position.x - global_position.x)
	facing_direction = direction
	animated_sprite.flip_h = (direction < 0)
	_update_directional_offsets()

	# Priority 1: If very close, stop and let AttackArea handle melee
	# (melee_stop_distance should be smaller than shooting ranges)
	if distance_to_target <= melee_stop_distance:
		velocity = Vector2.ZERO
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")
		# Don't return here - let AttackArea signal trigger melee attack
		return

	# Priority 2: If within shooting range, start shooting
	if distance_to_target <= shoot_range:
		if distance_to_target <= near_shoot_range:
			# Near range: rapid double shots with shot_1 animation
			_change_state(State.SHOOT_NEAR)
		else:
			# Far range: single shots with shot_2 animation, 2 second cooldown
			_change_state(State.SHOOT_FAR)
		return

	# Priority 3: Chase the target (too far to shoot)
	velocity.x = direction * move_speed

	if animated_sprite.animation != "run":
		animated_sprite.play("run")


func _state_returning() -> void:
	# Return to home position
	var distance_to_home: float = abs(global_position.x - home_position.x)

	if distance_to_home < 10.0:
		# Reached home, go back to idle or patrol
		velocity = Vector2.ZERO
		if behavior_type == BehaviorType.PATROL:
			_change_state(State.PATROL)
		else:
			_change_state(State.IDLE)
		return

	# Move towards home
	var direction: int = sign(home_position.x - global_position.x)
	facing_direction = direction
	velocity.x = direction * move_speed

	animated_sprite.flip_h = (direction < 0)
	_update_directional_offsets()

	if animated_sprite.animation != "run":
		animated_sprite.play("run")


func _state_attack() -> void:
	velocity = Vector2.ZERO


func _state_shoot_near() -> void:
	# Near shooting: continuous rapid fire with shot_1 animation
	velocity = Vector2.ZERO

	if is_instance_valid(target):
		var direction: int = sign(target.global_position.x - global_position.x)
		facing_direction = direction
		animated_sprite.flip_h = (direction < 0)
		_update_directional_offsets()


func _state_shoot_far() -> void:
	# Far shooting: single shots with 2 second pause
	velocity = Vector2.ZERO

	if is_instance_valid(target):
		var direction: int = sign(target.global_position.x - global_position.x)
		facing_direction = direction
		animated_sprite.flip_h = (direction < 0)
		_update_directional_offsets()


func _state_recharge() -> void:
	velocity = Vector2.ZERO


func _state_cooldown(delta: float) -> void:
	velocity = Vector2.ZERO

	# For far shooting, we use a timer-based cooldown
	if far_shoot_timer > 0:
		far_shoot_timer -= delta
		if far_shoot_timer <= 0:
			# Cooldown finished, check if we should continue shooting
			_check_shooting_state()
		return

	if animated_sprite.animation != "idle":
		animated_sprite.play("idle")


func _state_hurt() -> void:
	velocity = Vector2.ZERO


func _state_death() -> void:
	velocity = Vector2.ZERO


# Helper to return to home or idle based on behavior type
func _return_to_home_or_idle() -> void:
	var distance_from_home: float = abs(global_position.x - home_position.x)
	if distance_from_home > 10.0:
		_change_state(State.RETURNING)
	elif behavior_type == BehaviorType.PATROL:
		_change_state(State.PATROL)
	else:
		_change_state(State.IDLE)


# State transition
func _change_state(new_state: State) -> void:
	current_state = new_state

	match new_state:
		State.PATROL:
			# Reset patrol state when entering patrol mode
			is_waiting_at_endpoint = false
			animated_sprite.play("run")
		State.IDLE:
			velocity = Vector2.ZERO
			animated_sprite.play("idle")
		State.ATTACK:
			_do_attack()
		State.SHOOT_NEAR:
			_do_shoot_near()
		State.SHOOT_FAR:
			_do_shoot_far()
		State.RECHARGE:
			_do_reload()
		State.HURT:
			animated_sprite.play("hurt")
		State.DEATH:
			# Disable all collisions but keep animation visible
			set_collision_layer_value(2, false)
			set_collision_mask_value(2, false)
			# Also disable the hurtbox so bullets can pass through
			if hurtbox:
				hurtbox.set_collision_layer_value(3, false)
			animated_sprite.play("dead")


# Melee attack logic
func _do_attack() -> void:
	var attack_anim = ["attack_1", "attack_2"].pick_random()
	animated_sprite.play(attack_anim)


# Near shooting: double shot with shot_1 animation (two bullets with slight delay)
func _do_shoot_near() -> void:
	animated_sprite.play("shot_1")

	# Play random near shoot sound
	if audio_player and near_shoot_sounds.size() > 0:
		audio_player.stream = near_shoot_sounds.pick_random()
		audio_player.play()

	# Fire first bullet immediately, second bullet with slight delay
	_fire_near_bullet()

	# Use a short timer for the second bullet to create double-tap effect
	await get_tree().create_timer(0.08).timeout

	# Check if still in SHOOT_NEAR state and not dead before firing second bullet
	if current_state == State.SHOOT_NEAR and is_instance_valid(target):
		_fire_near_bullet()


# Helper function to fire a single bullet for near shooting
func _fire_near_bullet() -> void:
	if not bullet_scene or not is_instance_valid(target):
		return

	var base_dir := Vector2(facing_direction, 0).normalized()
	var bullet_speed := 600.0

	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	# Use ShootPoint2 for near shooting
	bullet.global_position = shoot_point_2.global_position

	# Add slight vertical angle variation for each bullet
	var spread := randf_range(-5.0, 5.0)
	var dir = base_dir.rotated(deg_to_rad(spread))
	bullet.setup(dir, bullet_damage, self, bullet_speed)

	current_ammo -= 1


# Far shooting: single shot with shot_2 animation
func _do_shoot_far() -> void:
	animated_sprite.play("shot_2")

	# Play random far shoot sound
	if audio_player and far_shoot_sounds.size() > 0:
		audio_player.stream = far_shoot_sounds.pick_random()
		audio_player.play()

	# Fire 1 bullet
	if bullet_scene and is_instance_valid(target):
		var base_dir := Vector2(facing_direction, 0).normalized()
		var bullet_speed := 600.0

		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = shoot_point.global_position
		bullet.setup(base_dir, bullet_damage, self, bullet_speed)

		current_ammo -= 1


# Reload logic
func _do_reload() -> void:
	animated_sprite.play("recharge")

	# Play reload sound
	if audio_player and reload_sound:
		audio_player.stream = reload_sound
		audio_player.play()


# Check what shooting state to enter based on distance
func _check_shooting_state() -> void:
	if not is_instance_valid(target):
		_return_to_home_or_idle()
		return

	# Check if we need to reload
	if current_ammo <= 0:
		_change_state(State.RECHARGE)
		return

	var distance_to_target: float = abs(target.global_position.x - global_position.x)

	# Check if player is still in attack range for melee
	var bodies_in_range = attack_area.get_overlapping_bodies()
	for body in bodies_in_range:
		if body.is_in_group("Player"):
			_change_state(State.ATTACK)
			return

	# Determine shooting mode based on distance
	if distance_to_target <= shoot_range:
		if distance_to_target <= near_shoot_range:
			_change_state(State.SHOOT_NEAR)
		else:
			_change_state(State.SHOOT_FAR)
	else:
		_change_state(State.CHASE)


# Deal damage when attack animation hits
func _deal_attack_damage() -> void:
	for body in attack_area.get_overlapping_bodies():
		if body.is_in_group("Player") and body.has_method("take_damage"):
			body.take_damage(attack_damage)


# Damage and death
func take_damage(amount: int, knockback: Vector2 = Vector2.ZERO) -> void:
	if current_state == State.DEATH:
		return
	
	health -= amount
	velocity = knockback
	
	if health <= 0:
		_change_state(State.DEATH)
	else:
		_change_state(State.HURT)


# Animation finished callback
func _on_animation_finished() -> void:
	match current_state:
		State.ATTACK:
			_deal_attack_damage()
			attack_cooldown.start()
			_change_state(State.COOLDOWN)
		State.SHOOT_NEAR:
			# Near shooting: immediately check for next action (continuous fire)
			_check_shooting_state()
		State.SHOOT_FAR:
			# Far shooting: enter cooldown with 2 second timer
			far_shoot_timer = far_shoot_cooldown
			_change_state(State.COOLDOWN)
		State.RECHARGE:
			# Reload complete, restore ammo and continue
			current_ammo = magazine_size
			_check_shooting_state()
		State.HURT:
			if is_instance_valid(target):
				_change_state(State.CHASE)
			else:
				_return_to_home_or_idle()
		State.DEATH:
			pass


# Signal callbacks
func _on_detection_area_body_entered(body: Node2D) -> void:
	# DEBUG: Print when any body enters detection area
	print("[AK47] Body entered DetectionArea: ", body.name, " Groups: ", body.get_groups())

	# Detection is purely based on DetectionArea - no distance check needed
	if body.is_in_group("Player"):
		print("[AK47] Player detected! Setting target and changing to CHASE state")
		target = body
		# Start chasing from idle, patrol, or returning states
		if current_state == State.IDLE or current_state == State.PATROL or current_state == State.RETURNING:
			_change_state(State.CHASE)


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
		if current_state in [State.CHASE, State.SHOOT_NEAR, State.SHOOT_FAR, State.COOLDOWN]:
			_return_to_home_or_idle()


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# Trigger melee attack from various states
		if current_state in [State.CHASE, State.PATROL, State.RETURNING, State.SHOOT_NEAR, State.SHOOT_FAR, State.COOLDOWN]:
			target = body  # Make sure we have target set
			_change_state(State.ATTACK)


func _on_attack_cooldown_timeout() -> void:
	# This is mainly for melee attack cooldown now
	if not is_instance_valid(target):
		_return_to_home_or_idle()
		return

	var bodies_in_range = attack_area.get_overlapping_bodies()
	var player_in_attack_range: bool = false

	for body in bodies_in_range:
		if body.is_in_group("Player"):
			player_in_attack_range = true
			break

	if player_in_attack_range:
		_change_state(State.ATTACK)
	elif is_instance_valid(target):
		_change_state(State.CHASE)
	else:
		_return_to_home_or_idle()
