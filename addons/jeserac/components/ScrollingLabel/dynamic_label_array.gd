tool
extends VBoxContainer
class_name VDynamicLabelArray

var labels: PoolStringArray = []    setget set_labels, get_labels

var REF_LABEL: Label = Label.new()
var style :StyleBoxEmpty = preload("res://addons/jeserac/components/ScrollingLabel/dynamic_label.tres")

func _get_property_list():
    return [
        {
            "class_name": "DynamicLabelArray",
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_CATEGORY,
            "name": "DynamicLabelArray",
            "type": TYPE_STRING
        },
        {
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "labels",
            "type": TYPE_ARRAY
        },
    ]

func _set(property, value):
    match property:
        "labels": 
            set_labels(value)
            return true

func _get(property):
    match property:
        "labels": 
            return get_labels()

func _ready():
    REF_LABEL.set("custom_styles/normal", style)
    set_labels(labels)

func set_labels(_labels: PoolStringArray) -> void:
    labels = _labels
    
    for label in get_children():
        label.queue_free()
    
    for label in labels:
        var t_lbl : Label = REF_LABEL.duplicate()
        t_lbl.set_text(label)
        t_lbl.set_visible(true)
        add_child(t_lbl)
        t_lbl.connect("tree_entered", self, "_on_child_added")
        t_lbl.connect("tree_exited", self, "_on_child_added")
        t_lbl.set_owner(self)

func get_labels() -> PoolStringArray:
    return labels

func _on_child_added():
    rect_size.y = labels.size() * 20
