extends Node2D

@onready var space_bg: Sprite2D      = $SpaceBackground
@onready var satellite: Sprite2D     = $Satellite
@onready var city_bg: Sprite2D       = $CityBackground
@onready var fade_rect: ColorRect    = $FadeRect
@onready var flash_rect: ColorRect   = $FlashRect
@onready var broadcast_label: RichTextLabel = $BroadcastLabel
@onready var bgm_player: AudioStreamPlayer  = $BgmPlayer

const NEXT_SCENE_PATH := "res://scenes/CharacterSelect.tscn"

func _ready() -> void:
	broadcast_label.add_theme_font_size_override("bold_font_size", 200)
	city_bg.visible = false
	flash_rect.modulate.a = 0.0
	fade_rect.modulate.a = 1.0
	broadcast_label.visible = false
	satellite.position = Vector2(1600, 300)

	bgm_player.play()

	play_cutscene()


func play_cutscene() -> void:
	await fade_in_from_black()
	await show_space_with_satellite()
	await transition_to_city()
	await white_flash_with_broadcast()
	await fade_out_and_change_scene()


func fade_in_from_black() -> void:
	var t := create_tween()
	t.tween_property(fade_rect, "modulate:a", 0.0, 1.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await t.finished


func show_space_with_satellite() -> void:
	var t := create_tween()
	t.tween_property(satellite, "position", Vector2(200, 300), 4.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await t.finished
	await get_tree().create_timer(1.0).timeout


func transition_to_city() -> void:
	city_bg.visible = true
	city_bg.modulate.a = 0.0

	var t := create_tween()
	t.parallel().tween_property(space_bg, "modulate:a", 0.0, 2.0)
	t.parallel().tween_property(city_bg, "modulate:a", 1.0, 2.0)
	await t.finished

	var t2 := create_tween()
	t2.tween_property(satellite, "modulate:a", 0.0, 1.5)
	await t2.finished

	await get_tree().create_timer(0.5).timeout


func white_flash_with_broadcast() -> void:
	var t := create_tween()
	flash_rect.modulate.a = 0.0
	t.tween_property(flash_rect, "modulate:a", 1.0, 0.2)
	t.tween_property(flash_rect, "modulate:a", 0.0, 1.0)
	await t.finished

	broadcast_label.text = "Global Memory Calibration Protocol initiated\nPlease remain calm; this is merely routine maintenance."
	broadcast_label.visible = true

	var t2 := create_tween()
	broadcast_label.modulate.a = 0.0
	t2.tween_property(broadcast_label, "modulate:a", 1.0, 1.0)
	await t2.finished

	await get_tree().create_timer(3.0).timeout


func fade_out_and_change_scene() -> void:
	fade_rect.modulate.a = 0.0
	var t := create_tween()
	t.tween_property(fade_rect, "modulate:a", 1.0, 1.5)
	await t.finished

	if ResourceLoader.exists(NEXT_SCENE_PATH):
		get_tree().change_scene_to_file(NEXT_SCENE_PATH)
	else:
		push_warning("NEXT_SCENE_PATH not found, stay in cutscene.")
