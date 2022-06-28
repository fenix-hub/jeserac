tool
extends EditorPlugin


func _enter_tree() -> void:
    print_debug("[jeserac] library activated")


func _exit_tree() -> void:
    print_debug("[jeserac] library deactivated")
