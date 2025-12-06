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
var is_being_picked_up: bool = false  # Prevent multiple pickups

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
	# Create a copy to avoid reference issues
	item_stack = stack.duplicate_stack()
	
	if item_stack and item_stack.item and item_stack.item.icon:
		if sprite:
			sprite.texture = item_stack.item.icon
	# item_pickup.gd (in setup)
	print("[ItemPickup.setup] got ", item_stack.item.name, " x", item_stack.quantity)

func _spawn_animation() -> void:
	# Pop up animation when spawned
	if sprite:
		sprite.scale = Vector2.ZERO
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(sprite, "scale", Vector2.ONE, 0.3)


func _process(delta: float) -> void:
	# Stop processing if already being picked up
	if is_being_picked_up:
		return
	
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
	if not can_pickup or is_being_picked_up:
		return
	
	if body.is_in_group("Player") or body.is_in_group("player"):
		target_player = body
		is_attracted = true


func _do_pickup() -> void:
	# Prevent multiple calls
	if is_being_picked_up:
		return
	
	is_being_picked_up = true
	set_process(false)  # Stop _process from running
	
	if item_stack == null or item_stack.item == null:
		queue_free()
		return
	
	print("[ItemPickup] Attempting to pick up ", item_stack.item.name, " x", item_stack.quantity)
	
	# Try to add to inventory
	var overflow: int = InventoryData.add_item(item_stack.item, item_stack.quantity)
	
	if overflow < item_stack.quantity:
		# At least some items were picked up
		var picked_up_amount: int = item_stack.quantity - overflow
		print("[ItemPickup] Successfully picked up ", picked_up_amount, " items")
		emit_signal("picked_up", item_stack)
		_play_pickup_sound()
		
		if overflow > 0:
			# Some items couldn't fit, update stack and drop back
			print("[ItemPickup] ", overflow, " items couldn't fit in inventory, dropping back")
			item_stack.quantity = overflow
			is_attracted = false
			is_being_picked_up = false
			target_player = null
			can_pickup = false
			time_alive = 0.0
			original_y = position.y
			set_process(true)  # Re-enable processing
		else:
			# All items picked up, destroy the pickup
			print("[ItemPickup] All items picked up, destroying pickup")
			_pickup_animation()
	else:
		# Inventory full, can't pick up any
		print("[ItemPickup] Inventory full! Couldn't pick up any items")
		is_attracted = false
		is_being_picked_up = false
		target_player = null
		set_process(true)  # Re-enable processing


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
