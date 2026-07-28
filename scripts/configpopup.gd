extends PopupPanel

var config: ConfigFile
var hotkey_scn: PackedScene = preload("uid://dsnbwqwajlqfd")
var hotkey_entries: Array[HotkeyEntry]

signal setting_changed(setting: StringName, value)

func _ready() -> void:
	if config:
		load_config()

func load_config():
	%HookPortSpinBox.set_value_no_signal(config.get_value("hook", "port", 22711))
	%VolumeSlider.set_value_no_signal(config.get_value("audio", "volume", 1.0))
	# Load hotkeys
	if config.has_section("hotkey"):
		for hotkey in config.get_section_keys("hotkey"):
			var hotkey_settings: Dictionary = config.get_value("hotkey", hotkey)
			var new_hotkey: HotkeyEntry = create_new_hotkey()
			new_hotkey.id = hotkey_settings["id"]
			new_hotkey.game = hotkey_settings["game"]
			new_hotkey.type = hotkey_settings["type"]
			new_hotkey.key = hotkey_settings["key"]
			new_hotkey.message = hotkey_settings["message"]
			new_hotkey.refresh_settings()

func _on_visibility_changed() -> void:
	if !visible: queue_free()


func _on_hook_port_spin_box_value_changed(value: float) -> void:
	setting_changed.emit(&"hook_port", int(value))
	config.set_value("hook", "port", value)
	config.save("user://sbmo.cfg")


func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(0, value)
	config.set_value("audio", "volume", value)
	config.save("user://sbmo.cfg")


func _on_add_hotkey_button_pressed() -> void:
	create_new_hotkey()

func create_new_hotkey() -> HotkeyEntry:
	var new_hotkey: Control = hotkey_scn.instantiate()
	new_hotkey.id = hotkey_entries.size()
	hotkey_entries.push_back(new_hotkey)
	%HotkeyContainer.add_child(new_hotkey)
	new_hotkey.hotkey_settings_changed.connect(apply_hotkey_settings)
	return new_hotkey

func apply_hotkey_settings(id: int, settings: Dictionary):
	config.set_value("hotkey", str(id), settings)
	config.save("user://sbmo.cfg")
	setting_changed.emit(&"hotkeys", hotkey_entries)
