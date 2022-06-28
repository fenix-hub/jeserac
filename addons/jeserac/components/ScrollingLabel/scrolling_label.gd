tool
extends Container
class_name ScrollingLabel

var index: int = 0
var animated: bool = true

onready var vdynamic_label_array: VDynamicLabelArray = get_node("VDynamicLabelArray")

onready var tween: Tween = get_node("Tween")

func _get_property_list():
    return [
        {
            "class_name": "ScrollingLabel",
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_CATEGORY,
            "name": "ScrollingLabel",
            "type": TYPE_STRING
        },
        {
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "index",
            "type": TYPE_INT
        },
        {
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "animated",
            "type": TYPE_BOOL
        },
    ]

func _set(property, value):
    match property:
        "index": 
            index = value
            move_to_index(index)
            return true
        "animated":
            animated = value
            return true

func _get(property):
    match property:
        "index": 
            return index
        "animated":
            return animated

func _ready():
    vdynamic_label_array.rect_position = Vector2.ZERO

func move_to_index(index: int) -> void:
    if vdynamic_label_array.get_child_count() < index:
        return
    var offset: int = index * vdynamic_label_array.get_child(0).rect_size.y
    if !animated:
        vdynamic_label_array.rect_position.y = - offset
    else:
        var factor : int = -1 if vdynamic_label_array.rect_position.y < offset else 1
        tween.interpolate_property(vdynamic_label_array, "rect_position:y", vdynamic_label_array.rect_position.y, offset * factor, 0.3, Tween.TRANS_EXPO, Tween.EASE_OUT)
        tween.start()
