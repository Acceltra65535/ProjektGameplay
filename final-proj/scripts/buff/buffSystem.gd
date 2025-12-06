extends Node
class_name BuffSystem

# Buff 类型
enum BuffType {
	SPEED,
	ATTACK,
	STAMINA_REGEN
}

# 每个 Buff 数据结构
class Buff:
	var type: int
	var value: float
	var duration: float
	var time_left: float

	func _init(_type, _value, _duration):
		type = _type
		value = _value
		duration = _duration
		time_left = _duration


var active_buffs: Array[Buff] = []


func add_buff(buff_type: int, value: float, duration: float) -> void:
	var buff := Buff.new(buff_type, value, duration)
	active_buffs.append(buff)


func get_total(buff_type: int) -> float:
	var total := 0.0
	for buff in active_buffs:
		if buff.type == buff_type:
			total += buff.value
	return total


func _process(delta: float) -> void:
	for buff in active_buffs:
		buff.time_left -= delta
	
	# 删除过期 Buff
	active_buffs = active_buffs.filter(
		func(b):
		return b.time_left > 0
	)
