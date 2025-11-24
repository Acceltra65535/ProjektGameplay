extends CharacterBody2D

# Character classes
enum CharacterClass { BALANCED, SPEED, TANK }

# Simple state machine
enum State { NORMAL, ATTACK, SHOT, RECHARGE, HURT, DEAD }

# Exported class selection (will be overridden by Global.selected_class)
@export var character_class: CharacterClass = CharacterClass.BALANCED

# SpriteFrames for each class
@export var frames_balanced: SpriteFrames
@export var frames_speed: SpriteFrames
@export var frames_tank: SpriteFrames

# Movement parameters
var walk_speed: float = 160.0
var run_speed: float = 260.0
const JUMP_VELOCITY: float = -420.0

# Gravity
var gravity: float = 0.0

# Stats
var max_health: int = 100
var health: int = 100
var max_stamina: int = 100
var stamina: int = 100

# Current state
var state: State = State.NORMAL

# Attack combo index for attack_1 and attack_2
var attack_combo_index: int = 0

# Jump buffer
var is_jump_buffered: bool = false
var jump_buffer_time: float = 0.3
var jump_timer: float = 0.0

# Cached AnimatedSprite2D
@onready var anim: AnimatedSprite2D = $Anim
# If your node is named "AnimatedSprite2D" instead, use:
# @onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	_apply_class_stats()
	_play_idle()


func _apply_class_stats() -> void:
	# Read selected class from Global singleton if available
	var cls: int = 0
	cls = Global.selected_class

	match cls:
		0:
			# Balanced class
			character_class = CharacterClass.BALANCED
			max_health = 100
			max_stamina = 100
			walk_speed = 160.0
			run_speed = 260.0
			if frames_balanced != null:
				anim.sprite_frames = frames_balanced
		1:
			# Speed class
			character_class = CharacterClass.SPEED
			max_health = 80
			max_stamina = 80
			walk_speed = 190.0
			run_speed = 300.0
			if frames_speed != null:
				anim.sprite_frames = frames_speed
		2:
			# Tank class
			character_class = CharacterClass.TANK
			max_health = 140
			max_stamina = 130
			walk_speed = 130.0
			run_speed = 210.0
			if frames_tank != null:
				anim.sprite_frames = frames_tank

	health = max_health
	stamina = max_stamina


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle delayed jump
	if is_jump_buffered:
		jump_timer -= delta
		if jump_timer <= 0.0:
			is_jump_buffered = false
			velocity.y = JUMP_VELOCITY

	var input_dir: float = 0.0

	# Only allow input in NORMAL state
	if state == State.NORMAL:
		input_dir = Input.get_axis("move_left", "move_right")

		# Jump (buffered)
		if Input.is_action_just_pressed("jump") and is_on_floor() and not is_jump_buffered:
			_start_jump_buffer()

		# Melee attack
		if Input.is_action_just_pressed("attack_melee"):
			_start_melee_attack()
		# Ranged shot
		elif Input.is_action_just_pressed("attack_ranged"):
			_start_shot()
		# Recharge
		elif Input.is_action_just_pressed("recharge"):
			_start_recharge()

	# Run or walk speed
	var is_running: bool = false
	if state == State.NORMAL and Input.is_action_pressed("run_mode"):
		is_running = true

	var current_speed: float = 0.0
	if is_running:
		current_speed = run_speed
	else:
		current_speed = walk_speed

	velocity.x = input_dir * current_speed

	# Flip sprite based on direction
	if velocity.x != 0.0:
		anim.flip_h = velocity.x < 0.0

	# Update animation according to state and movement
	_update_movement_animation()

	move_and_slide()


func _update_movement_animation() -> void:
	# Do not override special animations when not in NORMAL state
	if state != State.NORMAL:
		return

	# While jump is buffered, keep playing jump start animation on ground
	if is_jump_buffered:
		_play_if_not("jump_start")
		return

	# In air
	if not is_on_floor():
		_play_if_not("jump")
		return

	# On ground
	var moving: bool = abs(velocity.x) > 5.0
	var running: bool = Input.is_action_pressed("run_mode")

	if moving:
		if running:
			_play_if_not("run")
		else:
			_play_if_not("walk")
	else:
		_play_idle()


func _play_if_not(name: String) -> void:
	if anim.animation != name:
		anim.play(name)


func _play_idle() -> void:
	_play_if_not("idle")


func _start_jump_buffer() -> void:
	# Start jump delay on ground and play jump start animation
	is_jump_buffered = true
	jump_timer = jump_buffer_time
	_play_if_not("jump_start")


func _start_melee_attack() -> void:
	# Start melee combo only in NORMAL state
	if state != State.NORMAL:
		return

	state = State.ATTACK
	attack_combo_index = (attack_combo_index + 1) % 2
	if attack_combo_index == 0:
		anim.play("attack_1")
	else:
		anim.play("attack_2")
	# TODO add melee hitbox or damage logic here


func _start_shot() -> void:
	if state != State.NORMAL:
		return

	state = State.SHOT
	anim.play("shot")
	# TODO spawn projectile here


func _start_recharge() -> void:
	if state != State.NORMAL:
		return

	state = State.RECHARGE
	anim.play("recharge")
	# TODO restore stamina or ammo here


func take_damage(amount: int) -> void:
	# Call this when the player is hit by an enemy
	if state == State.DEAD:
		return

	health -= amount
	if health <= 0:
		health = 0
		state = State.DEAD
		anim.play("dead")
	else:
		state = State.HURT
		anim.play("hurt")


func _on_anim_animation_finished() -> void:
	var anim_name := anim.animation
	match anim_name:
		"attack_1", "attack_2", "shot", "recharge", "hurt":
			if state != State.DEAD:
				state = State.NORMAL
				_play_idle()
		"dead":
			state = State.DEAD
