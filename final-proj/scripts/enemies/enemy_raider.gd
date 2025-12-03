# res://scripts/enemies/enemy_raider.gd
extends CharacterBody2D
class_name EnemyRaider

# State enum
enum State { IDLE, PATROL, CHASE, ATTACK, AIMING, SHOOT, RECHARGE, COOLDOWN, HURT, DEATH, RETURNING }

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
@export var attack_cooldown_time: float = 2.0
@export var aim_time: float = 3.0
@export var knockback_force: float = 200.0
@export var bullet_scene: PackedScene

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
@export var shoot_range: float = 200.0            # Range to start shooting (patrol only)

# Node references
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var aim_timer: Timer = $AimTimer
@onready var shoot_point: Marker2D = $ShootPoint
@onready var hurtbox: Area2D = $Hurtbox

# Directional node original offsets (local positions)
var shoot_point_original_offset: Vector2 = Vector2.ZERO
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


func _ready() -> void:
	health = max_health
	attack_cooldown.wait_time = attack_cooldown_time
	attack_cooldown.one_shot = true
	aim_timer.wait_time = aim_time
	aim_timer.one_shot = true

	# Store spawn position as home for patrol/return behavior
	home_position = global_position

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
	aim_timer.timeout.connect(_on_aim_timer_timeout)
	animated_sprite.animation_finished.connect(_on_animation_finished)

	# Cache original local offsets for directional nodes
	if not directional_offsets_initialized:
		if shoot_point:
			shoot_point_original_offset = shoot_point.position
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
		State.AIMING:
			_state_aiming()
		State.SHOOT:
			_state_shoot()
		State.RECHARGE:
			_state_recharge()
		State.COOLDOWN:
			_state_cooldown()
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
	if not is_instance_valid(target):
		_return_to_home_or_idle()
		return

	var distance_to_target: float = abs(target.global_position.x - global_position.x)
	var distance_from_home: float = abs(global_position.x - home_position.x)

	# Determine max chase distance based on behavior type
	var max_chase: float = guard_chase_distance if behavior_type == BehaviorType.GUARD else patrol_chase_distance

	# Check if we've chased too far from home
	if distance_from_home > max_chase:
		target = null
		_change_state(State.RETURNING)
		return

	# For patrol type: if target is far, start aiming to shoot
	if behavior_type == BehaviorType.PATROL and distance_to_target > shoot_range:
		_change_state(State.AIMING)
		return

	# Stop moving when close enough for melee attack (prevents stacking on player)
	if distance_to_target <= melee_stop_distance:
		velocity = Vector2.ZERO
		# Face the target
		var direction: int = sign(target.global_position.x - global_position.x)
		facing_direction = direction
		animated_sprite.flip_h = (direction < 0)
		_update_directional_offsets()
		if animated_sprite.animation != "idle":
			animated_sprite.play("idle")
		return

	# Chase the target
	var direction: int = sign(target.global_position.x - global_position.x)
	facing_direction = direction
	velocity.x = direction * move_speed

	animated_sprite.flip_h = (direction < 0)
	_update_directional_offsets()

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


func _state_aiming() -> void:
	velocity = Vector2.ZERO

	if is_instance_valid(target):
		var direction: int = sign(target.global_position.x - global_position.x)
		facing_direction = direction
		animated_sprite.flip_h = (direction < 0)
		_update_directional_offsets()


func _state_shoot() -> void:
	velocity = Vector2.ZERO


func _state_recharge() -> void:
	velocity = Vector2.ZERO


func _state_cooldown() -> void:
	velocity = Vector2.ZERO
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
	if current_state == State.AIMING:
		aim_timer.stop()

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
		State.AIMING:
			animated_sprite.play("shot")
			animated_sprite.pause()
			aim_timer.start()
		State.SHOOT:
			_do_shoot()
		State.RECHARGE:
			animated_sprite.play("recharge")
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


# Ranged attack logic
func _do_shoot() -> void:
	if bullet_scene and is_instance_valid(target):
		var base_dir := Vector2(facing_direction, 0).normalized()

		var angle_list := [-5.0, 0.0, 5.0]

		for angle_deg in angle_list:
			var bullet = bullet_scene.instantiate()
			get_tree().current_scene.add_child(bullet)

			bullet.global_position = shoot_point.global_position

			var angle_rad = deg_to_rad(angle_deg)
			var dir = base_dir.rotated(angle_rad)

			var bullet_speed = 600.0
			bullet.setup(dir, bullet_damage, self, bullet_speed)

	_change_state(State.RECHARGE)


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
		State.RECHARGE:
			attack_cooldown.start()
			_change_state(State.COOLDOWN)
		State.HURT:
			if is_instance_valid(target):
				_change_state(State.CHASE)
			else:
				_return_to_home_or_idle()
		State.DEATH:
			pass


# Signal callbacks
func _on_detection_area_body_entered(body: Node2D) -> void:
	# Detection is purely based on DetectionArea - no distance check needed
	if body.is_in_group("Player"):
		target = body
		# Start chasing from idle, patrol, or returning states
		if current_state == State.IDLE or current_state == State.PATROL or current_state == State.RETURNING:
			_change_state(State.CHASE)


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
		if current_state == State.CHASE or current_state == State.AIMING:
			_return_to_home_or_idle()


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		# Trigger attack from chase, aiming, patrol, or returning states
		if current_state in [State.CHASE, State.AIMING, State.PATROL, State.RETURNING]:
			target = body  # Make sure we have target set
			_change_state(State.ATTACK)


func _on_attack_cooldown_timeout() -> void:
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


func _on_aim_timer_timeout() -> void:
	if current_state == State.AIMING:
		animated_sprite.play("shot")
		_change_state(State.SHOOT)
