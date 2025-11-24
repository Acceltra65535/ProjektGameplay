extends CharacterBody2D

# Character classes
enum CharacterClass { BALANCED, SPEED, TANK }

# Simple state machine for the player
enum State { NORMAL, ATTACK, SHOT, RECHARGE, HURT, DEAD }

# Selected class for this player
@export var character_class: CharacterClass = CharacterClass.BALANCED

# Base movement and jump
const BASE_MOVE_SPEED: float = 200.0
const JUMP_VELOCITY: float = -420.0
const RUN_MULTIPLIER: float = 1.4

# Gravity from project settings
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# Stats that depend on the class
var move_speed: float
var max_health: int
var max_stamina: int

# Current values
var health: int
var stamina: int

# Current state
var state: State = State.NORMAL

# Attack combo index for attack_1 and attack_2
var attack_combo_index: int = 0

# Cache AnimatedSprite2D
@onready var anim: AnimatedSprite2D = $Anim


func _ready() -> void:
	# If there is a global selection then use it
	if Engine.has_singleton("Global"):
		var idx: int = Global.selected_class
		if idx == 0:
			character_class = CharacterClass.BALANCED
		elif idx == 1:
			character_class = CharacterClass.SPEED
		elif idx == 2:
			character_class = CharacterClass.TANK
			
	_apply_stats_for_class()
	_play_idle()


func _apply_stats_for_class() -> void:
	# Set stats based on the selected character class
	match character_class:
		CharacterClass.BALANCED:
			max_health = 100
			max_stamina = 100
			move_speed = BASE_MOVE_SPEED
		CharacterClass.SPEED:
			max_health = 80
			max_stamina = 80
			move_speed = BASE_MOVE_SPEED * 1.3
		CharacterClass.TANK:
			max_health = 130
			max_stamina = 130
			move_speed = BASE_MOVE_SPEED * 0.75

	health = max_health
	stamina = max_stamina


func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	var input_dir: float = 0.0

	# Only allow input in NORMAL state
	if state == State.NORMAL:
		input_dir = Input.get_axis("move_left", "move_right")

		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY

		# Melee attack
		if Input.is_action_just_pressed("attack_melee"):
			_start_melee_attack()
		# Ranged shot
		elif Input.is_action_just_pressed("attack_ranged"):
			_start_shot()
		# Recharge
		elif Input.is_action_just_pressed("recharge"):
			_start_recharge()

	# Decide current horizontal speed
	var is_running: bool = state == State.NORMAL and Input.is_action_pressed("run_mode")
	var current_speed: float = move_speed
	if is_running:
		current_speed *= RUN_MULTIPLIER

	velocity.x = input_dir * current_speed

	# Flip sprite based on movement direction
	if velocity.x != 0.0:
		anim.flip_h = velocity.x < 0.0

	# Update movement related animation when in NORMAL state
	_update_movement_animation()

	move_and_slide()


func _update_movement_animation() -> void:
	# Do not override special animations
	if state != State.NORMAL:
		return

	# In air
	if not is_on_floor():
		_play_if_not("jump")
		return

	# On ground
	var moving: bool = abs(velocity.x) > 5.0
	if moving:
		var is_running: bool = Input.is_action_pressed("run_mode")
		if is_running:
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


func _start_melee_attack() -> void:
	state = State.ATTACK
	attack_combo_index = (attack_combo_index + 1) % 2
	if attack_combo_index == 0:
		anim.play("attack_1")
	else:
		anim.play("attack_2")
	# TODO add melee hitbox or damage logic here


func _start_shot() -> void:
	state = State.SHOT
	anim.play("shot")
	# TODO spawn projectile here


func _start_recharge() -> void:
	state = State.RECHARGE
	anim.play("recharge")
	# TODO restore stamina or ammo here


func take_damage(amount: int) -> void:
	# Call this function when the player is hit by an enemy
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

func _on_animated_sprite_2d_animation_finished(anim_name: StringName) -> void:
	# This function is called when any animation finishes
	match anim_name: 
		"attack_1", "attack_2", "shot", "recharge", "hurt":
			if state != State.DEAD:
				state = State.NORMAL
				_play_idle()
		"dead":
			state = State.DEAD
			
