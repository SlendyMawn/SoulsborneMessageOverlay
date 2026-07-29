extends Control

signal message_text_updated(new_text: String)

enum MessageGame {DeS, DS1, DS2, DS3, BB, SK, ER, ERNR, DB}

var config: ConfigFile = ConfigFile.new()
var config_popup_scn: PackedScene = preload("uid://doysj8jswuwjo")
var config_popup: PopupPanel

var hotkeys: Array[HotkeyEntry]
# Godot keycodes 'almost' line up with windows ones. probably some formula behind it but i cant be fucked tbh, enormous fuckass lookup table, go!
var VK_TO_GODOT_KEY: Dictionary = {
	0x08: Key.KEY_BACKSPACE,
	0x09: Key.KEY_TAB,
	0x0C: Key.KEY_CLEAR,
	0x0D: Key.KEY_ENTER,
	0x10: Key.KEY_SHIFT,
	0x11: Key.KEY_CTRL,
	0x12: Key.KEY_ALT,
	0x13: Key.KEY_PAUSE,
	0x14: Key.KEY_CAPSLOCK,
	0x1B: Key.KEY_ESCAPE,
	0x20: Key.KEY_SPACE,
	0x21: Key.KEY_PAGEUP,
	0x22: Key.KEY_PAGEDOWN,
	0x23: Key.KEY_END,
	0x24: Key.KEY_HOME,
	0x25: Key.KEY_LEFT,
	0x26: Key.KEY_UP,
	0x27: Key.KEY_RIGHT,
	0x28: Key.KEY_DOWN,
	0x2C: Key.KEY_PRINT,
	0x2D: Key.KEY_INSERT,
	0x2E: Key.KEY_DELETE,
	0x30: Key.KEY_0,
	0x31: Key.KEY_1,
	0x32: Key.KEY_2,
	0x33: Key.KEY_3,
	0x34: Key.KEY_4,
	0x35: Key.KEY_5,
	0x36: Key.KEY_6,
	0x37: Key.KEY_7,
	0x38: Key.KEY_8,
	0x39: Key.KEY_9,
	0x41: Key.KEY_A,
	0x42: Key.KEY_B,
	0x43: Key.KEY_C,
	0x44: Key.KEY_D,
	0x45: Key.KEY_E,
	0x46: Key.KEY_F,
	0x47: Key.KEY_G,
	0x48: Key.KEY_H,
	0x49: Key.KEY_I,
	0x4A: Key.KEY_J,
	0x4B: Key.KEY_K,
	0x4C: Key.KEY_L,
	0x4D: Key.KEY_M,
	0x4E: Key.KEY_N,
	0x4F: Key.KEY_O,
	0x50: Key.KEY_P,
	0x51: Key.KEY_Q,
	0x52: Key.KEY_R,
	0x53: Key.KEY_S,
	0x54: Key.KEY_T,
	0x55: Key.KEY_U,
	0x56: Key.KEY_V,
	0x57: Key.KEY_W,
	0x58: Key.KEY_X,
	0x59: Key.KEY_Y,
	0x5A: Key.KEY_Z,
	0x5B: Key.KEY_META,
	0x5C: Key.KEY_META,
	0x5D: Key.KEY_MENU,
	0x60: Key.KEY_KP_0,
	0x61: Key.KEY_KP_1,
	0x62: Key.KEY_KP_2,
	0x63: Key.KEY_KP_3,
	0x64: Key.KEY_KP_4,
	0x65: Key.KEY_KP_5,
	0x66: Key.KEY_KP_6,
	0x67: Key.KEY_KP_7,
	0x68: Key.KEY_KP_8,
	0x69: Key.KEY_KP_9,
	0x6A: Key.KEY_KP_MULTIPLY,
	0x6B: Key.KEY_KP_ADD,
	0x6C: Key.KEY_KP_PERIOD,
	0x6D: Key.KEY_KP_SUBTRACT,
	0x6E: Key.KEY_KP_PERIOD,
	0x6F: Key.KEY_KP_DIVIDE,
	0x70: Key.KEY_F1,
	0x71: Key.KEY_F2,
	0x72: Key.KEY_F3,
	0x73: Key.KEY_F4,
	0x74: Key.KEY_F5,
	0x75: Key.KEY_F6,
	0x76: Key.KEY_F7,
	0x77: Key.KEY_F8,
	0x78: Key.KEY_F9,
	0x79: Key.KEY_F10,
	0x7A: Key.KEY_F11,
	0x7B: Key.KEY_F12,
	0x7C: Key.KEY_F13,
	0x7D: Key.KEY_F14,
	0x7E: Key.KEY_F15,
	0x7F: Key.KEY_F16,
	0x80: Key.KEY_F17,
	0x81: Key.KEY_F18,
	0x82: Key.KEY_F19,
	0x83: Key.KEY_F20,
	0x84: Key.KEY_F21,
	0x85: Key.KEY_F22,
	0x86: Key.KEY_F23,
	0x87: Key.KEY_F24,
	0x90: Key.KEY_NUMLOCK,
	0x91: Key.KEY_SCROLLLOCK,
	0xA0: Key.KEY_SHIFT,
	0xA1: Key.KEY_SHIFT,
	0xA2: Key.KEY_CTRL,
	0xA3: Key.KEY_CTRL,
	0xA4: Key.KEY_ALT,
	0xA5: Key.KEY_ALT,
	0xBA: Key.KEY_SEMICOLON,
	0xBB: Key.KEY_EQUAL,
	0xBC: Key.KEY_COMMA,
	0xBD: Key.KEY_MINUS,
	0xBE: Key.KEY_PERIOD,
	0xBF: Key.KEY_SLASH,
	0xC0: Key.KEY_QUOTELEFT,
	0xDB: Key.KEY_BRACKETLEFT,
	0xDC: Key.KEY_BACKSLASH,
	0xDD: Key.KEY_BRACKETRIGHT,
	0xDE: Key.KEY_APOSTROPHE
}

# Hook
var hook_enabled: bool = true
var hook: UDPServer = UDPServer.new()
var hook_port: int = 22711

func _ready() -> void:
	# Allow mouse passthrough
	if Engine.has_singleton("MousePassthrough"):
		MousePassthrough.set_passthrough(get_window().get_window_id(), true)
	# TODO: Find a way of hiding the app in the taskbar. (Hack with C++?)
	# Read config (if available)
	config_popup = config_popup_scn.instantiate()
	if config.load("user://sbmo.cfg") == OK:
		hook_enabled = config.get_value("hook", "enabled", true)
		hook_port = config.get_value("hook", "port", 22711)
		AudioServer.set_bus_volume_linear(0, config.get_value("audio", "volume", 1.0))
		config_popup.config = config
	config_popup.setting_changed.connect(update_setting)
	add_child(config_popup)
	config_popup.popup()
	# Ugly hack to load hotkeys from config menu on startup. Centralize this stuff in a persistent autoload script?
	if !config.get_value("config", "showonstart", true):
		config_popup._on_close_requested()
		config_popup.queue_free()

func _process(delta: float) -> void:
	if hook_enabled:
		if !hook.is_listening():
			hook.listen(hook_port)
		_process_hook()
	else:
		if hook.is_listening():
			hook.stop()

func trigger_message(game: int, type: int, message: String):
	# Do not play during another message
	if %MessageAnimation.is_playing():
		return
	var message_anim: StringName = "message_%s_%s" % [MessageGame.find_key(game), type]
	if !%MessageAnimation.has_animation(message_anim):
		print("Message animation '%s' was not found, this message game/type may be unsupported!" % message_anim)
		%ErrorLabel.text = "Message animation '%s' was not found, this message game/type may be unsupported!" % message_anim
		%MessageAnimation.play("error")
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

# This might be slow, come up with something better?
func _on_hotkey_daemon_on_key_pressed(value: int) -> void:
	if !config_popup:
		for hotkey in hotkeys:
			# Sometimes these hotkeys get freed here and are still iterated on?
			if hotkey:
				if hotkey.key == VK_TO_GODOT_KEY.get(value):
					trigger_message(hotkey.game, hotkey.type, hotkey.message)
