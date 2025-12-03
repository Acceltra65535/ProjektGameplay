extends Area2D
class_name ItemPickup

## Represents an item dropped in the world that can be picked up.

signal picked_up(stack: ItemStack)

@export var bob_height: float = 4.0
@export var bob_speed: float = 2.0
@export var attract_speed: float = 300.0
@export var attract_distance: float = 50.0
@export var auto_pickup_delay: float = 0.3  # Delay before item can be picked up

var item_stack: ItemStack
var original_y: float = 0.0
var time_alive: float = 0.0
var can_pickup: bool = false
var is_attracted: bool = false
var target_player: Node2D = null

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var pickup_sound: AudioStreamPlayer2D = $PickupSound


func _ready() -> void:
	original_y = position.y
	
	# Set up collision to detect player
	collision_layer = 0
	collision_mask = 1  # Player layer
	
	body_entered.connect(_on_body_entered)
	
	# Initial spawn animation
	_spawn_animation()


func setup(stack: ItemStack) -> void:
	item_stack = stack
	
	if stack and stack.item and stack.item.icon:
		if sprite:
			sprite.texture = stack.item.icon


func _spawn_animation() -> void:
	# Pop up animation when spawned
	if sprite:
		sprite.scale = Vector2.ZERO
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(sprite, "scale", Vector2.ONE, 0.3)


func _process(delta: float) -> void:
	time_alive += delta
	
	# Enable pickup after delay
	if not can_pickup and time_alive >= auto_pickup_delay:
		can_pickup = true
	
	# Bobbing animation
	if not is_attracted:
		position.y = original_y + sin(time_alive * bob_speed) * bob_height
	
	# Attract to player if close enough
	if is_attracted and target_player:
		var direction: Vector2 = (target_player.global_position - global_position).normalized()
		global_position += direction * attract_speed * delta
		
		# Check if reached player
		if global_position.distance_to(target_player.global_position) < 20:
			_do_pickup()


func _on_body_entered(body: Node2D) -> void:
	if not can_pickup:
		return
	
	if body.is_in_group("Player") or body.is_in_group("player"):
		target_player = body
		is_attracted = true


func _do_pickup() -> void:
	if item_stack == null or item_stack.item == null:
		queue_free()
		return
	
	# Try to add to inventory
	var overflow: int = InventoryData.add_item(item_stack.item, item_stack.quantity)
	
	if overflow < item_stack.quantity:
		# At least some items were picked up
		emit_signal("picked_up", item_stack)
		_play_pickup_sound()
		
		if overflow > 0:
			# Some items couldn't fit, update stack and drop back
			item_stack.quantity = overflow
			is_attracted = false
			target_player = null
			can_pickup = false
			time_alive = 0.0
			original_y = position.y
		else:
			# All items picked up
			_pickup_animation()
	else:
		# Inventory full, can't pick up
		is_attracted = false
		target_player = null


func _play_pickup_sound() -> void:
	if pickup_sound and pickup_sound.stream:
		pickup_sound.play()


func _pickup_animation() -> void:
	# Quick scale down and fade
	if sprite:
		var tween: Tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite, "scale", Vector2.ZERO, 0.15)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.15)
		tween.chain().tween_callback(queue_free)
	else:
		queue_free()
