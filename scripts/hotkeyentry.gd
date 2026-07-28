class_name HotkeyEntry
extends HBoxContainer

signal hotkey_settings_changed(id: int, settings: Dictionary)

var id: int
var key: Key = KEY_KP_MULTIPLY
var game: int = 6
var type: int = 0
var message: String

func _ready() -> void:
	set_process_unhandled_key_input(false)

func refresh_settings() -> void:
	$GameSelection.selected = game
	$TypeSelection.set_value_no_signal(type)
	$MessageSelection.text = message
	$KeySelection.text = OS.get_keycode_string(key)

func _on_game_selection_item_selected(index: int) -> void:
	game = index
	submit_settings()

func _on_type_selection_value_changed(value: float) -> void:
	type = int(value)
	submit_settings()

func _on_message_selection_text_changed(new_text: String) -> void:
	message = new_text
	submit_settings()

func submit_settings():
	hotkey_settings_changed.emit(id, {"id":id,"key":key,"game":game,"type":type,"message":message})

func _on_key_selection_toggled(toggled_on: bool) -> void:
	$KeySelection.text = "..." if toggled_on else OS.get_keycode_string(key)
	set_process_unhandled_key_input(toggled_on)

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey:
		set_process_unhandled_key_input(false)
		key = event.keycode
		$KeySelection.button_pressed = false
		submit_settings()
