#pragma once

#include <godot_cpp/classes/node.hpp>

namespace godot {

class HotkeyDaemon : public Node {
	GDCLASS(HotkeyDaemon, Node)


protected:
	static void _bind_methods();

public:
	int last_key;
	void _process(double delta) override;
};

}
