extends CharacterBody2D

# Command scripts
const PlayerCommand = preload("res://scripts/commands/command.gd")
const MoveCommand = preload("res://scripts/commands/move_command.gd")
const JumpCommand = preload("res://scripts/commands/jump_command.gd")
const MeleeAttackCommand = preload("res://scripts/commands/melee_attack_command.gd")
const ShotCommand = preload("res://scripts/commands/shot_command.gd")
const RechargeCommand = preload("res://scripts/commands/recharge_command.gd")

# Projectile scene
const ProjectileScene = preload("res://scenes/Projectile.tscn")

# Character classes
enum CharacterClass { BALANCED, SPEED, TANK }

# Simple state machine
enum State { NORMAL, ATTACK, SHOT, RECHARGE, HURT, DEAD }

# Environment for weapon sounds (near/far)
enum EnvironmentType { SMALL, OPEN }

# Hit material types
enum HitMaterial { GENERIC, METAL, WOOD, FLESH, STONE }

# Surface types for footsteps
enum SurfaceType { ROAD, GRASS }

# Weapon kind
enum WeaponKind { RIFLE, PISTOL_1911, PISTOL_1917 }

# Exported class selection (will be overridden by Global.selected_class)
@export var character_class: CharacterClass = CharacterClass.BALANCED

# SpriteFrames for each class
@export var frames_balanced: SpriteFrames
@export var frames_speed: SpriteFrames
@export var frames_tank: SpriteFrames

@onready var body_shape: CollisionShape2D = $CollisionShape2D

# Movement parameters
var walk_speed: float = 100.0
var run_speed: float = 260.0
const JUMP_VELOCITY: float = -420.0

# Gravity
var gravity: float = 0.0

# Stats
var max_health: int = 100
var health: int = 100
var max_stamina: int = 100
var stamina: float = 100.0

# Stamina rates
var stamina_regen_rate: float = 15.0      # per second
var stamina_run_cost_rate: float = 20.0   # per second

# Melee and gun damage
var melee_damage: float = 20.0
var weapon_base_damage: float = 30.0

# Weapon + ammo
var weapon_kind: WeaponKind = WeaponKind.RIFLE
var mag_capacity: int = 0
var current_mag: int = 0
var reserve_ammo: int = 0

const RIFLE_INITIAL_AMMO: int = 20
const PISTOL_INITIAL_AMMO: int = 60

# Current state
var state: State = State.NORMAL

# Attack combo index for attack_1 and attack_2
var attack_combo_index: int = 0

# Jump buffer
var is_jump_buffered: bool = false
var jump_buffer_time: float = 0.3
var jump_timer: float = 0.0

# Environment for gun sounds (default small indoor scene)
var environment_type: EnvironmentType = EnvironmentType.SMALL

# Surface type for footsteps (road / grass)
var surface_type: SurfaceType = SurfaceType.ROAD

# Running flag (used by animation and footsteps)
var is_running: bool = false

# Footstep timer
var footstep_timer: float = 0.0

# Cached AnimatedSprite2D
@onready var anim: AnimatedSprite2D = $Anim

# Audio players (add these as children of Player)
@onready var voice_player: AudioStreamPlayer2D = $VoicePlayer
@onready var gun_player: AudioStreamPlayer2D = $GunPlayer
@onready var reload_player: AudioStreamPlayer2D = $ReloadPlayer
@onready var hit_player: AudioStreamPlayer2D = $HitPlayer
@onready var footstep_player: AudioStreamPlayer2D = $FootstepPlayer

# Hitbox / Hurtbox / Muzzle
@onready var melee_hitbox: Area2D = $MeleeHitbox
@onready var hurtbox: Area2D = $Hurtbox
@onready var muzzle: Node2D = $Muzzle

@onready var melee_hitbox_collision: CollisionShape2D = $MeleeHitbox/CollisionShape2D
@onready var hurtbox_collision: CollisionShape2D = $Hurtbox/CollisionShape2D

# Original local offsets for directional nodes
var muzzle_original_offset: Vector2 = Vector2.ZERO
var melee_hitbox_original_offset: Vector2 = Vector2.ZERO
var hurtbox_original_offset: Vector2 = Vector2.ZERO
var directional_offsets_initialized: bool = false

# Voice clips
var jump_voice_clips: Array[AudioStream] = []
var attack_voice_clips: Array[AudioStream] = []
var light_hurt_voice_clips: Array[AudioStream] = []
var heavy_hurt_voice_clips: Array[AudioStream] = []
var death_voice_clips: Array[AudioStream] = []

# Weapon clips
var gun_near_clips: Array[AudioStream] = []
var gun_far_clips: Array[AudioStream] = []
var reload_clips: Array[AudioStream] = []

# Hit clips by material
var generic_hit_clips: Array[AudioStream] = []
var metal_hit_clips: Array[AudioStream] = []
var wood_hit_clips: Array[AudioStream] = []
var flesh_hit_clips: Array[AudioStream] = []

# Footstep clips (shared by all characters, to be assigned later)
var footstep_road_clips: Array[AudioStream] = []
var footstep_grass_clips: Array[AudioStream] = []

# Last used indices to avoid repeats
var last_jump_index: int = -1
var last_attack_voice_index: int = -1
var last_light_hurt_index: int = -1
var last_heavy_hurt_index: int = -1
var last_death_index: int = -1
var last_shot_index: int = -1
var last_reload_index: int = -1
var last_generic_hit_index: int = -1
var last_metal_hit_index: int = -1
var last_wood_hit_index: int = -1
var last_flesh_hit_index: int = -1
var last_footstep_index: int = -1

# Commands
var move_command: PlayerCommand
var jump_command: PlayerCommand
var melee_command: PlayerCommand
var shot_command: PlayerCommand
var recharge_command: PlayerCommand

var is_frozen: bool = false


func _ready() -> void:
	randomize()
	gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
	_apply_class_stats()
	_load_audio_for_class()
	_load_hit_sounds()
	_create_commands()
	_play_idle()

	if melee_hitbox:
		melee_hitbox.monitoring = false

	# Configure collision: Player on layer 1, don't collide with layer 2 (enemies)
	set_collision_layer_value(1, true)   # Player is on layer 1
	set_collision_mask_value(2, false)   # Don't collide with enemies (layer 2)

	# Cache original offsets for directional nodes
	if not directional_offsets_initialized:
		if muzzle:
			muzzle_original_offset = muzzle.position
		if melee_hitbox:
			melee_hitbox_original_offset = melee_hitbox_collision.position
		if hurtbox:
			hurtbox_original_offset = hurtbox_collision.position
		directional_offsets_initialized = true
		_update_directional_offsets()


func _create_commands() -> void:
	move_command = MoveCommand.new()
	jump_command = JumpCommand.new()
	melee_command = MeleeAttackCommand.new()
	shot_command = ShotCommand.new()
	recharge_command = RechargeCommand.new()


func _apply_class_stats() -> void:
	var cls: int = 0
	cls = Global.selected_class

	match cls:
		0:
			# Balanced: rifle, highest gun damage, medium melee, medium stamina usage
			character_class = CharacterClass.BALANCED
			max_health = 100
			max_stamina = 100
			walk_speed = 90.0
			run_speed = 220.0
			stamina_regen_rate = 18.0
			stamina_run_cost_rate = 22.0
			melee_damage = 20.0
			weapon_base_damage = 45.0
			weapon_kind = WeaponKind.RIFLE
			mag_capacity = 1
			current_mag = 1
			reserve_ammo = RIFLE_INITIAL_AMMO - current_mag
			if frames_balanced != null:
				anim.sprite_frames = frames_balanced
		1:
			# Speed: 1911 pistol, lowest melee, fastest stamina drain
			character_class = CharacterClass.SPEED
			max_health = 80
			max_stamina = 80
			walk_speed = 100.0
			run_speed = 250.0
			stamina_regen_rate = 20.0
			stamina_run_cost_rate = 30.0
			melee_damage = 18.0
			weapon_base_damage = 30.0
			weapon_kind = WeaponKind.PISTOL_1911
			mag_capacity = 7  # standard 1911 mag
			current_mag = mag_capacity
			reserve_ammo = PISTOL_INITIAL_AMMO - current_mag
			if frames_speed != null:
				anim.sprite_frames = frames_speed
		2:
			# Tank: 1917 revolver, highest melee, slowest stamina drain
			character_class = CharacterClass.TANK
			max_health = 140
			max_stamina = 130
			walk_speed = 80.0
			run_speed = 200.0
			stamina_regen_rate = 15.0
			stamina_run_cost_rate = 18.0
			melee_damage = 22.0
			weapon_base_damage = 32.0
			weapon_kind = WeaponKind.PISTOL_1917
			mag_capacity = 6  # 1917 revolver cylinder
			current_mag = mag_capacity
			reserve_ammo = PISTOL_INITIAL_AMMO - current_mag
			if frames_tank != null:
				anim.sprite_frames = frames_tank

	health = max_health
	stamina = float(max_stamina)


func set_frozen(value: bool) -> void:
	is_frozen = value
	if is_frozen:
		# Stop horizontal movement immediately when frozen
		velocity.x = 0.0


func _physics_process(delta: float) -> void:
	if is_frozen:
		# Still apply gravity so the player can land nicely,
		# but ignore input and commands.
		if not is_on_floor():
			velocity.y += gravity * delta
		move_and_slide()
		return

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle delayed jump
	if is_jump_buffered:
		jump_timer -= delta
		if jump_timer <= 0.0:
			is_jump_buffered = false
			velocity.y = JUMP_VELOCITY

	# Execute commands (input -> high level intent)
	move_command.execute(self, delta)
	jump_command.execute(self, delta)
	melee_command.execute(self, delta)
	shot_command.execute(self, delta)
	recharge_command.execute(self, delta)
	
	# Prevent Slide
	if (state == State.RECHARGE) or (state == State.ATTACK) or (state == State.SHOT) or (state == State.DEAD):
		velocity.x = 0

	# Footsteps based on current velocity and surface
	_update_footsteps(delta)

	# Update facing and directional nodes
	_update_facing_and_offsets()

	# Update animation according to state and movement
	_update_movement_animation()

	move_and_slide()


# Called by MoveCommand
func handle_move(input_dir: float, wants_run: bool, delta: float) -> void:
	if state != State.NORMAL:
		velocity.x = 0.0
		is_running = false
		return

	var moving: bool = abs(input_dir) > 0.01

	# Running only if there is stamina and player is moving
	var target_running: bool = wants_run and moving and stamina > 0.0
	is_running = target_running

	if is_running:
		stamina -= stamina_run_cost_rate * delta
		if stamina <= 0.0:
			stamina = 0.0
			is_running = false
	else:
		# Regenerate stamina when not running
		stamina += stamina_regen_rate * delta
		if stamina > max_stamina:
			stamina = float(max_stamina)

	var current_speed: float = walk_speed
	if is_running:
		current_speed = run_speed

	velocity.x = input_dir * current_speed

	# Flip sprite
	if velocity.x != 0.0:
		anim.flip_h = velocity.x < 0.0
		_update_directional_offsets()


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

	if moving:
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


func _start_jump_buffer() -> void:
	# Start jump delay and play jump start animation and voice
	if state != State.NORMAL:
		return

	is_jump_buffered = true
	jump_timer = jump_buffer_time
	_play_if_not("jump_start")
	_play_jump_voice()


func _start_melee_attack() -> void:
	if state != State.NORMAL:
		return

	state = State.ATTACK
	attack_combo_index = (attack_combo_index + 1) % 2
	if attack_combo_index == 0:
		anim.play("attack_1")
	else:
		anim.play("attack_2")

	_enable_melee_hitbox()
	_play_attack_voice()
	# Damage is applied in _on_melee_hitbox_body_entered


func _start_shot() -> void:
	if state != State.NORMAL:
		return

	# Check ammo in magazine
	if current_mag <= 0:
		# No ammo, try reload if we still have reserve
		if reserve_ammo > 0:
			_start_recharge()
		return

	state = State.SHOT
	anim.play("shot")

	current_mag -= 1
	_play_gun_shot()
	_spawn_projectile()
	# Note: no voice here, only gun sound


func _start_recharge() -> void:
	if state != State.NORMAL:
		return

	# No reserve ammo, cannot reload
	if reserve_ammo <= 0:
		return

	state = State.RECHARGE
	anim.play("recharge")
	_play_reload()

	# Rifle loads one round, pistols fill magazine
	if weapon_kind == WeaponKind.RIFLE:
		_reload_one_round()
	else:
		_reload_full_mag()


func _reload_one_round() -> void:
	if mag_capacity <= 0:
		return
	if current_mag >= mag_capacity:
		return
	if reserve_ammo <= 0:
		return

	current_mag += 1
	reserve_ammo -= 1


func _reload_full_mag() -> void:
	if mag_capacity <= 0:
		return

	var need: int = mag_capacity - current_mag
	if need <= 0:
		return
	if reserve_ammo <= 0:
		return

	var to_load: int = min(need, reserve_ammo)
	current_mag += to_load
	reserve_ammo -= to_load

func _update_directional_offsets() -> void:
	if not directional_offsets_initialized:
		return

	var sign := 1.0
	if anim.flip_h:
		sign = -1.0

	# Muzzle around the center
	if muzzle:
		muzzle.position = Vector2(
			abs(muzzle_original_offset.x) * sign,
			muzzle_original_offset.y
		)

	# Melee hitbox: mirror horizontally
	if melee_hitbox:
		melee_hitbox_collision.position = Vector2(
			abs(melee_hitbox_original_offset.x) * sign,
			melee_hitbox_original_offset.y
		)

	if hurtbox:
		hurtbox_collision.position = Vector2(
			abs(hurtbox_original_offset.x) * sign,
			hurtbox_original_offset.y
		)

func _update_facing_and_offsets() -> void:
	if velocity.x == 0.0:
		return

	var new_flip: bool = velocity.x < 0.0
	if new_flip != anim.flip_h:
		anim.flip_h = new_flip
	_update_directional_offsets()

func _spawn_projectile() -> void:
	if ProjectileScene == null:
		return

	var projectile = ProjectileScene.instantiate()
	var spawn_pos: Vector2 = global_position
	if muzzle:
		spawn_pos = muzzle.global_position
	projectile.global_position = spawn_pos

	var dir: Vector2 = Vector2.RIGHT
	if anim.flip_h:
		dir = Vector2.LEFT

	# Default material is flesh (for enemies); can be overridden by enemy
	if projectile.has_method("setup"):
		projectile.setup(dir, weapon_base_damage, self, HitMaterial.FLESH)

	get_tree().current_scene.add_child(projectile)


func take_damage(amount: int) -> void:
	if state == State.DEAD:
		return

	health -= amount
	if health <= 0:
		health = 0
		state = State.DEAD
		anim.play("dead")
		_play_death_voice()
	else:
		state = State.HURT
		anim.play("hurt")
		_play_hurt_voice()


func _on_anim_animation_finished() -> void:
	var anim_name := anim.animation
	match anim_name:
		"attack_1", "attack_2":
			_disable_melee_hitbox()
			if state != State.DEAD:
				state = State.NORMAL
				_play_idle()
		"shot", "recharge", "hurt":
			if state != State.DEAD:
				state = State.NORMAL
				_play_idle()
		"dead":
			state = State.DEAD


func _enable_melee_hitbox() -> void:
	if melee_hitbox:
		melee_hitbox.monitoring = true


func _disable_melee_hitbox() -> void:
	if melee_hitbox:
		melee_hitbox.monitoring = false


func _on_melee_hitbox_area_entered(area: Area2D) -> void:
	if state != State.ATTACK:
		return
	if area == self:
		return

	var body = area.get_parent()
	
	if body == self:
		return
	
	if body.has_method("take_damage"):
		if body is Destructible:
			body.take_damage(int(melee_damage))
		elif body.has_method("get_hit_material"):
			var knockback_dir: Vector2 = Vector2(1 if not anim.flip_h else -1, -0.3).normalized()
			var knockback: Vector2 = knockback_dir * 150.0
			body.take_damage(int(melee_damage), knockback)
		else:
			body.take_damage(int(melee_damage))

	var material: int = HitMaterial.FLESH
	if body.has_method("get_hit_material"):
		material = body.get_hit_material()

	play_hit_sound(material)



func _on_hurtbox_area_entered(area: Area2D) -> void:
	# enemy attack areas should have `damage` and `owner`
	if area.has_method("get_attack_damage"):
		var dmg: int = area.get_attack_damage()
		take_damage(dmg)


# --------- Audio loading per class ---------

func _load_audio_for_class() -> void:
	jump_voice_clips.clear()
	attack_voice_clips.clear()
	light_hurt_voice_clips.clear()
	heavy_hurt_voice_clips.clear()
	death_voice_clips.clear()
	gun_near_clips.clear()
	gun_far_clips.clear()
	reload_clips.clear()

	match character_class:
		CharacterClass.BALANCED:
			_load_male1_voice()
			_load_sks_gun()
		CharacterClass.SPEED:
			_load_female_voice()
			_load_1911_gun()
		CharacterClass.TANK:
			_load_male2_voice()
			_load_1917_gun()


func _load_male1_voice() -> void:
	jump_voice_clips = [
		load("res://audio/MaleCharacter/male1_jump.wav"),
		load("res://audio/MaleCharacter/male1_jump2.wav"),
		load("res://audio/MaleCharacter/male1_jump3.wav")
	]

	attack_voice_clips = [
		load("res://audio/MaleCharacter/male1_hit.wav"),
		load("res://audio/MaleCharacter/male1_hit2.wav"),
		load("res://audio/MaleCharacter/male1_hit3.wav")
	]

	light_hurt_voice_clips = [
		load("res://audio/MaleCharacter/male1_hurt.wav"),
		load("res://audio/MaleCharacter/male1_hurt2.wav")
	]

	heavy_hurt_voice_clips = [
		load("res://audio/MaleCharacter/male1_hurts.wav"),
		load("res://audio/MaleCharacter/male1_hurts2.wav")
	]

	death_voice_clips = [
		load("res://audio/MaleCharacter/male1_death.wav"),
		load("res://audio/MaleCharacter/male1_death2.wav"),
		load("res://audio/MaleCharacter/male1_death3.wav"),
		load("res://audio/MaleCharacter/male1_death4.wav")
	]


func _load_male2_voice() -> void:
	jump_voice_clips = [
		load("res://audio/MaleCharacter/male2_jump.wav"),
		load("res://audio/MaleCharacter/male2_jump2.wav"),
		load("res://audio/MaleCharacter/male2_jump3.wav"),
		load("res://audio/MaleCharacter/male2_jump4.wav")
	]

	attack_voice_clips = [
		load("res://audio/MaleCharacter/male2_hit.wav"),
		load("res://audio/MaleCharacter/male2_hit2.wav"),
		load("res://audio/MaleCharacter/male2_hit3.wav"),
		load("res://audio/MaleCharacter/male2_hit4.wav")
	]

	light_hurt_voice_clips = [
		load("res://audio/MaleCharacter/male2_hurt.wav"),
		load("res://audio/MaleCharacter/male2_hurt2.wav")
	]

	heavy_hurt_voice_clips = [
		load("res://audio/MaleCharacter/male2_hurts.wav"),
		load("res://audio/MaleCharacter/male2_hurts2.wav"),
		load("res://audio/MaleCharacter/male2_hurts3.wav")
	]

	death_voice_clips = [
		load("res://audio/MaleCharacter/male2_death.wav"),
		load("res://audio/MaleCharacter/male2_death2.wav"),
		load("res://audio/MaleCharacter/male2_death3.wav"),
		load("res://audio/MaleCharacter/male2_death4.wav")
	]


func _load_female_voice() -> void:
	jump_voice_clips = [
		load("res://audio/FemaleCharacter/female_jump.wav"),
		load("res://audio/FemaleCharacter/female_jump2.wav"),
		load("res://audio/FemaleCharacter/female_jump3.wav"),
		load("res://audio/FemaleCharacter/female_jump4.wav"),
		load("res://audio/FemaleCharacter/female_jump5.wav"),
		load("res://audio/FemaleCharacter/female_jump6.wav"),
		load("res://audio/FemaleCharacter/female_jump7.wav"),
		load("res://audio/FemaleCharacter/female_jump8.wav")
	]

	attack_voice_clips = [
		load("res://audio/FemaleCharacter/female_hit.wav"),
		load("res://audio/FemaleCharacter/female_hit2.wav"),
		load("res://audio/FemaleCharacter/female_hit3.wav"),
		load("res://audio/FemaleCharacter/female_hit4.wav"),
		load("res://audio/FemaleCharacter/female_hit5.wav"),
		load("res://audio/FemaleCharacter/female_hit6.wav")
	]

	light_hurt_voice_clips = [
		load("res://audio/FemaleCharacter/female_hurt.wav"),
		load("res://audio/FemaleCharacter/female_hurt2.wav"),
		load("res://audio/FemaleCharacter/female_hurt3.wav"),
		load("res://audio/FemaleCharacter/female_hurt4.wav"),
		load("res://audio/FemaleCharacter/female_hurt5.wav")
	]

	heavy_hurt_voice_clips = [
		load("res://audio/FemaleCharacter/female_hurts.wav"),
		load("res://audio/FemaleCharacter/female_hurts2.wav"),
		load("res://audio/FemaleCharacter/female_hurts3.wav"),
		load("res://audio/FemaleCharacter/female_hurts4.wav"),
		load("res://audio/FemaleCharacter/female_hurts5.wav"),
		load("res://audio/FemaleCharacter/female_hurts6.wav"),
		load("res://audio/FemaleCharacter/female_hurts7.wav"),
		load("res://audio/FemaleCharacter/female_hurts8.wav")
	]

	death_voice_clips = [
		load("res://audio/FemaleCharacter/female_death.wav"),
		load("res://audio/FemaleCharacter/female_death2.wav"),
		load("res://audio/FemaleCharacter/female_death3.wav")
	]


func _load_sks_gun() -> void:
	gun_near_clips = [
		load("res://audio/Prepared SFX Library/SKS/sks_near.wav"),
		load("res://audio/Prepared SFX Library/SKS/sks_near2.wav"),
		load("res://audio/Prepared SFX Library/SKS/sks_near3.wav")
	]

	gun_far_clips = [
		load("res://audio/Prepared SFX Library/SKS/sks_far.wav"),
		load("res://audio/Prepared SFX Library/SKS/sks_far2.wav"),
		load("res://audio/Prepared SFX Library/SKS/sks_far3.wav"),
		load("res://audio/Prepared SFX Library/SKS/sks_far4.wav")
	]

	reload_clips = [
		load("res://audio/Prepared SFX Library/SKS/Lever Reload WAV.wav")
	]


func _load_1911_gun() -> void:
	gun_near_clips = [
		load("res://audio/Prepared SFX Library/1911/1911_near.wav"),
		load("res://audio/Prepared SFX Library/1911/1911_near2.wav")
	]

	gun_far_clips = [
		load("res://audio/Prepared SFX Library/1911/1911_far.wav"),
		load("res://audio/Prepared SFX Library/1911/1911_far2.wav")
	]

	reload_clips = [
		load("res://audio/Prepared SFX Library/1911/Semi 22LR Reload Full WAV.wav")
	]


func _load_1917_gun() -> void:
	gun_near_clips = [
		load("res://audio/Prepared SFX Library/1917/1917_near.wav"),
		load("res://audio/Prepared SFX Library/1917/1917_near2.wav")
	]

	gun_far_clips = [
		load("res://audio/Prepared SFX Library/1917/1917_far.wav"),
		load("res://audio/Prepared SFX Library/1917/1917_far2.wav")
	]

	reload_clips = [
		load("res://audio/Prepared SFX Library/1917/Semi 22LR Reload Part 2 WAV.wav")
	]


func _load_hit_sounds() -> void:
	generic_hit_clips = [
		load("res://audio/Hits/Hit.wav"),
	]

	metal_hit_clips = [
		load("res://audio/Hits/Metal Hit 1.wav"),
		load("res://audio/Hits/Metal Hit 2.wav"),
		load("res://audio/Hits/Metal Hit 3.wav"),
		load("res://audio/Hits/Metal Hit 4.wav"),
		load("res://audio/Hits/Metal Hit 5.wav"),
		load("res://audio/Hits/Metal Hit 6.wav"),
		load("res://audio/Hits/Metal Hit.wav"),
		load("res://audio/Hits/Hard Hits.wav"),
		load("res://audio/Hits/Hard Metal Hits.wav"),
		load("res://audio/Hits/Harder Metal Hits.wav"),
		load("res://audio/Hits/Moving Metal Hits.wav"),
		load("res://audio/Hits/Moving Metal Hits 1.wav"),
		load("res://audio/Hits/Plain Metal Hits.wav"),
		load("res://audio/Hits/Plain Metal Hits 1.wav")
	]

	wood_hit_clips = [
		load("res://audio/Hits/Wood Hits.wav"),
		load("res://audio/Hits/Wood Hits 1.wav"),
		load("res://audio/Hits/Wood Hits 2.wav")
	]

	# Flesh hits can be added later if you have dedicated assets
	flesh_hit_clips = []


# --------- Audio playback helpers ---------

func _play_random_from(player: AudioStreamPlayer2D, clips: Array[AudioStream], last_index_ref: String) -> void:
	if clips.is_empty():
		return

	var last_index: int = get(last_index_ref)
	var idx: int = randi() % clips.size()
	if clips.size() > 1 and idx == last_index:
		idx = (idx + 1) % clips.size()

	set(last_index_ref, idx)
	player.stream = clips[idx]
	player.play()


func _play_jump_voice() -> void:
	_play_random_from(voice_player, jump_voice_clips, "last_jump_index")


func _play_attack_voice() -> void:
	_play_random_from(voice_player, attack_voice_clips, "last_attack_voice_index")


func _play_hurt_voice() -> void:
	var ratio: float = 1.0
	if max_health > 0:
		ratio = float(health) / float(max_health)

	if ratio <= 0.6 and not heavy_hurt_voice_clips.is_empty():
		_play_random_from(voice_player, heavy_hurt_voice_clips, "last_heavy_hurt_index")
	else:
		_play_random_from(voice_player, light_hurt_voice_clips, "last_light_hurt_index")


func _play_death_voice() -> void:
	_play_random_from(voice_player, death_voice_clips, "last_death_index")


func _play_gun_shot() -> void:
	var clips: Array[AudioStream] = gun_near_clips
	if environment_type == EnvironmentType.OPEN and not gun_far_clips.is_empty():
		clips = gun_far_clips

	_play_random_from(gun_player, clips, "last_shot_index")


func _play_reload() -> void:
	_play_random_from(reload_player, reload_clips, "last_reload_index")


func play_hit_sound(material: HitMaterial) -> void:
	match material:
		HitMaterial.METAL:
			_play_random_from(hit_player, metal_hit_clips, "last_metal_hit_index")
		HitMaterial.WOOD:
			_play_random_from(hit_player, wood_hit_clips, "last_wood_hit_index")
		HitMaterial.FLESH:
			if flesh_hit_clips.is_empty():
				_play_random_from(hit_player, generic_hit_clips, "last_generic_hit_index")
			else:
				_play_random_from(hit_player, flesh_hit_clips, "last_flesh_hit_index")
		_:
			_play_random_from(hit_player, generic_hit_clips, "last_generic_hit_index")


func set_environment_type(new_type: EnvironmentType) -> void:
	environment_type = new_type


func set_surface_type(new_type: SurfaceType) -> void:
	surface_type = new_type


func _update_footsteps(delta: float) -> void:
	if state != State.NORMAL:
		footstep_timer = 0.0
		return

	var on_ground: bool = is_on_floor()
	var moving: bool = abs(velocity.x) > 5.0

	if not on_ground or not moving:
		footstep_timer = 0.0
		return

	var interval: float = 0.5
	if is_running:
		interval = 0.3

	footstep_timer -= delta
	if footstep_timer <= 0.0:
		footstep_timer = interval
		_play_footstep()


func _play_footstep() -> void:
	var clips: Array[AudioStream] = []
	match surface_type:
		SurfaceType.ROAD:
			clips = footstep_road_clips
		SurfaceType.GRASS:
			clips = footstep_grass_clips

	_play_random_from(footstep_player, clips, "last_footstep_index")
