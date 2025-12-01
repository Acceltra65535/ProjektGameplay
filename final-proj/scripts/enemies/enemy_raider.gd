# res://scripts/enemies/enemy_raider.gd
extends CharacterBody2D
class_name EnemyRaider

# State enum
enum State { IDLE, CHASE, ATTACK, AIMING, SHOOT, RECHARGE, COOLDOWN, HURT, DEATH }

# Export variables
@export var move_speed: float = 150.0
@export var max_health: int = 50
@export var attack_damage: int = 10
@export var bullet_damage: float = 15.0
@export var attack_cooldown_time: float = 2.0
@export var aim_time: float = 3.0
@export var knockback_force: float = 200.0
@export var shoot_range: float = 200.0
@export var bullet_scene: PackedScene

# Node references
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detection_area: Area2D = $DetectionArea
@onready var attack_area: Area2D = $AttackArea
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var aim_timer: Timer = $AimTimer
@onready var shoot_point: Marker2D = $ShootPoint
@onready var hurtbox: CollisionShape2D = $AttackArea/CollisionShape2D

# Directional node original offsets (local positions)
var shoot_point_original_offset: Vector2 = Vector2.ZERO
var attack_area_original_offset: Vector2 = Vector2.ZERO
var hurtbox_original_offset: Vector2 = Vector2.ZERO
var directional_offsets_initialized: bool = false

# State variables
var current_state: State = State.IDLE
var health: int
var target: Node2D = null
var facing_direction: int = -1  # -1 left, 1 right

var is_frozen: bool = false


func _ready() -> void:
	health = max_health
	attack_cooldown.wait_time = attack_cooldown_time
	attack_cooldown.one_shot = true
	aim_timer.wait_time = aim_time
	aim_timer.one_shot = true
	
	# Connect signals
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_cooldown.timeout.connect(_on_attack_cooldown_timeout)
	aim_timer.timeout.connect(_on_aim_timer_timeout)
	animated_sprite.animation_finished.connect(_on_animation_finished)
	
	animated_sprite.play("idle")
	
		# Cache original local offsets for directional nodes
	if not directional_offsets_initialized:
		if shoot_point:
			shoot_point_original_offset = shoot_point.position
		if attack_area:
			attack_area_original_offset = attack_area.position
		if hurtbox:
			hurtbox_original_offset = hurtbox.position

		directional_offsets_initialized = true
		_update_directional_offsets()


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
	
	move_and_slide()


func _update_directional_offsets() -> void:
	# Update directional nodes (shoot point, hitbox, hurtbox) based on current flip state.
	if not directional_offsets_initialized:
		return

	var sign := 1.0
	if animated_sprite.flip_h:
		# When facing left, mirror on X axis
		sign = -1.0

	if shoot_point:
		shoot_point.position = Vector2(
			abs(shoot_point_original_offset.x) * sign,
			shoot_point_original_offset.y
		)

	if attack_area:
		attack_area.position = Vector2(
			abs(attack_area_original_offset.x) * sign,
			attack_area_original_offset.y
		)

	if hurtbox:
		hurtbox.position = Vector2(
			abs(hurtbox_original_offset.x) * sign,
			hurtbox_original_offset.y
		)
		

# State logic
func _state_idle() -> void:
	velocity = Vector2.ZERO
	if animated_sprite.animation != "idle":
		animated_sprite.play("idle")


func _state_chase() -> void:
	if not is_instance_valid(target):
		_change_state(State.IDLE)
		return
	
	var distance = abs(target.global_position.x - global_position.x)
	
	if distance > shoot_range:
		_change_state(State.AIMING)
		return
	
	var direction = sign(target.global_position.x - global_position.x)
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
		var direction = sign(target.global_position.x - global_position.x)
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


# State transition
func _change_state(new_state: State) -> void:
	if current_state == State.AIMING:
		aim_timer.stop()
	
	current_state = new_state
	
	match new_state:
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
			set_collision_layer_value(1, false)
			set_collision_mask_value(1, false)
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
			var knockback_dir = sign(body.global_position.x - global_position.x)
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
			if target:
				_change_state(State.CHASE)
			else:
				_change_state(State.IDLE)
		State.DEATH:
			queue_free()


# Signal callbacks
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		target = body
		if current_state == State.IDLE:
			_change_state(State.CHASE)


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == target:
		target = null
		if current_state == State.CHASE or current_state == State.AIMING:
			_change_state(State.IDLE)


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if current_state == State.CHASE or current_state == State.AIMING:
			_change_state(State.ATTACK)


func _on_attack_cooldown_timeout() -> void:
	if not is_instance_valid(target):
		_change_state(State.IDLE)
		return
	
	var bodies_in_range = attack_area.get_overlapping_bodies()
	var player_in_attack_range = false
	
	for body in bodies_in_range:
		if body.is_in_group("Player"):
			player_in_attack_range = true
			break
	
	if player_in_attack_range:
		_change_state(State.ATTACK)
	elif target:
		_change_state(State.CHASE)
	else:
		_change_state(State.IDLE)


func _on_aim_timer_timeout() -> void:
	if current_state == State.AIMING:
		animated_sprite.play("shot")
		_change_state(State.SHOOT)
