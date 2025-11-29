extends Area2D
class_name Projectile

@export var speed: float = 3000.0
@export var max_distance: float = 900.0

var direction: Vector2 = Vector2.RIGHT
var base_damage: float = 30.0
var shooter: Node = null
var default_hit_material: int = 0
var traveled: float = 0.0


func setup(dir: Vector2, damage: float, shooter_ref: Node, hit_material: int) -> void:
	direction = dir.normalized()
	base_damage = damage
	shooter = shooter_ref
	default_hit_material = hit_material


func _physics_process(delta: float) -> void:
	var move_vec: Vector2 = direction * speed * delta
	position += move_vec
	traveled += move_vec.length()

	if traveled >= max_distance:
		queue_free()
		return

	var bodies := get_overlapping_bodies()
	for body in bodies:
		if body == shooter:
			continue

		# Distance-based small damage falloff (up to -20%)
		var distance_ratio: float = clamp(traveled / max_distance, 0.0, 1.0)
		var damage_factor: float = 1.0 - 0.2 * distance_ratio
		var damage: int = int(round(base_damage * damage_factor))

		if body.has_method("take_damage"):
			body.take_damage(damage)

		var material: int = default_hit_material
		if body.has_method("get_hit_material"):
			material = body.get_hit_material()

		if shooter != null and shooter.has_method("play_hit_sound"):
			shooter.play_hit_sound(material)

		queue_free()
		break
