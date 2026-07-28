extends Control

signal message_text_updated(new_text: String)

enum MessageGame {DeS, DS1, DS2, DS3, BB, SK, ER, ERNR, DB}

var config: ConfigFile = ConfigFile.new()
var config_popup_scn: PackedScene = preload("uid://doysj8jswuwjo")
var config_popup: PopupPanel

var hotkeys: Array[HotkeyEntry]

# Hook
var hook: UDPServer = UDPServer.new()
var hook_port: int = 22711

func _ready() -> void:
	# Allow mouse passthrough
	if Engine.has_singleton("MousePassthrough"):
		MousePassthrough.set_passthrough(get_window().get_window_id(), true)
	# TODO: Find a way of hiding the app in the taskbar. (Hack with C++?)
	# Read config (if available)
	if config.load("user://sbmo.cfg") == OK:
		if !config.get_value("hook", "enabled", true):
			hook = null
		else:
			hook_port = config.get_value("hook", "port", 22711)
		AudioServer.set_bus_volume_linear(0, config.get_value("audio", "volume", 1.0))
	if hook:
		hook.listen(hook_port)

func _process(delta: float) -> void:
	if hook:
		_process_hook()

func trigger_message(game: int, type: int, message: String):
	var message_anim: StringName = "message_%s_%s" % [MessageGame.find_key(game), type]
	if !%MessageAnimation.has_animation(message_anim):
		print("Message animation '%s' was not found, this message game/type may be unsupported!" % message_anim)
		return
	message_text_updated.emit(message)
	%MessageAnimation.play(message_anim)

func process_command(raw_command: String) -> Array:
	var processed_command: Array = []
	processed_command.resize(3)
	var command_csv: PackedStringArray = raw_command.split("¶", false)
	if command_csv.is_empty(): return []
	processed_command[0] = command_csv[0] as int
	processed_command[1] = command_csv[1] as int
	processed_command[2] = command_csv[2] as String
	return processed_command

func _process_hook():
	hook.poll()
	if hook.is_connection_available():
		var peer: PacketPeerUDP = hook.take_connection()
		var packet: PackedByteArray = peer.get_packet()
		var raw_command: String = packet.get_string_from_utf8()
		if !raw_command: return
		print("[Hook] Received command: %s" % raw_command)
		peer.put_packet(packet)
		var command: Array = process_command(raw_command)
		trigger_message.callv(command)


func _on_tray_menu_index_pressed(index: int) -> void:
	match index:
		0:
			if config_popup:
				config_popup.hide()
			config_popup = config_popup_scn.instantiate()
			if config: config_popup.config = config
			config_popup.setting_changed.connect(update_setting)
			add_child(config_popup)
			config_popup.popup()
		1:
			get_tree().quit()

func update_setting(setting: StringName, value):
	set(setting, value)
