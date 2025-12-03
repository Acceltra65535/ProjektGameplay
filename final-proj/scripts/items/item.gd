extends Resource
class_name Item

@export var id: String = ""
@export var name: String = ""
@export var description: String = ""
@export var icon: Texture2D
@export var max_stack: int = 99
@export var item_type: ItemType = ItemType.RESOURCE

enum ItemType {
	RESOURCE,
	CONSUMABLE,
	WEAPON,
	AMMO,
	KEY_ITEM
}
