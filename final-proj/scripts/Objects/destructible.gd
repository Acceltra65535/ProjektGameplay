extends StaticBody2D
class_name Destructible

## Base class for destructible objects like crates, barrels, containers.
## Attach different sprites and loot tables to create varied containers.

signal destroyed
signal damaged(amount: int, remaining_health: int)

@export_group("Stats")
@export var max_health: int = 30
@export var current_health: int = 30

@export_group("Loot")
@export var loot_table: LootTable
@export var drop_on_destroy: bool = true

@export_group("Visuals")
@export var destroy_particles: PackedScene  # Optional particle effect
@export var damaged_texture: Texture2D      # Optional damaged state texture

@export_group("Audio")
@export var hit_sounds: Array[AudioStream] = []
@export var destroy_sound: AudioStream

# Node references
@onready var sprite: Sprite2D = $Sprite2D
@onready var hurtbox: Area2D = $Hurtbox
@onready var audio_player: AudioStreamPlayer2D = $AudioPlayer

var is_destroyed: bool = false
var original_texture: Texture2D


func _ready() -> void:
	current_health = max_health
	
	if sprite:
		original_texture = sprite.texture
	
	# Set up collision layers
	# Layer 4 is for hurtboxes (can be hit by player attacks)
	if hurtbox:
		hurtbox.collision_layer = 4
		hurtbox.collision_mask = 0


func take_damage(amount: int) -> void:
	if is_destroyed:
		return
	
	current_health -= amount
	emit_signal("damaged", amount, current_health)
	
	_play_hit_sound()
	_on_damaged()
	
	if current_health <= 0:
		_destroy()


func _on_damaged() -> void:
	# Show damaged texture if health is low
	if damaged_texture and sprite:
		var health_ratio: float = float(current_health) / float(max_health)
		if health_ratio < 0.5:
			sprite.texture = damaged_texture
	
	# Visual feedback - shake or flash
	_do_damage_feedback()


func _do_damage_feedback() -> void:
	# Quick shake effect
	if sprite:
		var original_pos: Vector2 = sprite.position
		var tween: Tween = create_tween()
		tween.tween_property(sprite, "position", original_pos + Vector2(4, 0), 0.05)
		tween.tween_property(sprite, "position", original_pos + Vector2(-4, 0), 0.05)
		tween.tween_property(sprite, "position", original_pos, 0.05)


func _destroy() -> void:
	if is_destroyed:
		return
	
	is_destroyed = true
	emit_signal("destroyed")
	
	_play_destroy_sound()
	_spawn_particles()
	
	if drop_on_destroy:
		_drop_loot()
	
	# Disable collision
	if hurtbox:
		hurtbox.set_deferred("monitoring", false)
		hurtbox.set_deferred("monitorable", false)
	
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	
	# Fade out and remove
	if sprite:
		var tween: Tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
		tween.tween_callback(queue_free)
	else:
		queue_free()


func _drop_loot() -> void:
	if loot_table == null:
		return
	
	var drops: Array[ItemStack] = loot_table.roll_loot()
	
	for stack in drops:
		_spawn_pickup(stack)


func _spawn_pickup(stack: ItemStack) -> void:
	"""Spawn a pickup item in the world."""
	if stack == null or stack.item == null:
		return
	
	# Use call_deferred to spawn after physics processing is done
	call_deferred("_spawn_pickup_deferred", stack)


func _spawn_pickup_deferred(stack: ItemStack) -> void:
	"""Actually spawn the pickup (called deferred)."""
	var pickup_scene: PackedScene = preload("res://scenes/item_pickup.tscn")
	var pickup: Node2D = pickup_scene.instantiate()
	
	# Random offset for visual spread
	var offset: Vector2 = Vector2(
		randf_range(-20, 20),
		randf_range(-10, 10)
	)
	
	pickup.global_position = global_position + offset
	pickup.setup(stack)
	
	get_tree().current_scene.add_child(pickup)

func _spawn_particles() -> void:
	if destroy_particles == null:
		return
	
	var particles: Node2D = destroy_particles.instantiate()
	particles.global_position = global_position
	get_tree().current_scene.add_child(particles)
	
	# Auto-cleanup particles after some time
	if particles.has_method("set_emitting"):
		particles.set_emitting(true)
	
	var timer: SceneTreeTimer = get_tree().create_timer(2.0)
	timer.timeout.connect(particles.queue_free)


func _play_hit_sound() -> void:
	if audio_player == null:
		return
	if hit_sounds.is_empty():
		return
	
	var sound: AudioStream = hit_sounds[randi() % hit_sounds.size()]
	audio_player.stream = sound
	audio_player.play()


func _play_destroy_sound() -> void:
	if audio_player == null:
		return
	if destroy_sound == null:
		return
	
	audio_player.stream = destroy_sound
	audio_player.play()


# For compatibility with player's attack system
func get_hit_material() -> int:
	# Return WOOD by default for containers
	# 0 = GENERIC, 1 = METAL, 2 = WOOD, 3 = FLESH, 4 = STONE
	return 2  # WOOD
