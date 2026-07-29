#ifndef HOTKEYDAEMON_REGISTER_TYPES_H
#define HOTKEYDAEMON_REGISTER_TYPES_H

#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void initialize_hotkey_module(ModuleInitializationLevel p_level);
void uninitialize_hotkey_module(ModuleInitializationLevel p_level);

#endif // HOTKEYDAEMON_REGISTER_TYPES_H