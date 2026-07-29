#pragma comment(lib, "User32.lib")
#include "hotkeydaemon.h"
#include <windows.h>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/classes/node.hpp>


using namespace godot;


void HotkeyDaemon::_bind_methods() {
    ADD_SIGNAL(MethodInfo("on_key_pressed", PropertyInfo(Variant::INT, "value")));
}

void HotkeyDaemon::_process(double delta) {
    // Really? THIS is how we get which keys are pressed any time? REALLY? ay cabron...
    for (int vkCode = 1; vkCode < 256; ++vkCode) {
        if (GetAsyncKeyState(vkCode) & 0x8000) {
            last_key = vkCode;
            emit_signal("on_key_pressed", last_key);
        }
    }
}
