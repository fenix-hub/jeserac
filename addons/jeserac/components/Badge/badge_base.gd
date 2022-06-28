tool
extends PanelContainer
class_name Badge

signal count_updated(new_value)
signal overflow_reached()

var count: int = 0                      setget set_count,get_count
var overflow_count: int = 99            setget set_overflow_count,get_overflow_count
var show_zero: bool = true              setget set_show_zero
var color: Color = Color("#ff002a")     setget set_color
var animated: bool = true               setget set_is_animated
var dot: bool = false                   setget set_is_dot
var show_badge: bool = true             setget set_show_badge
var badge_scale: float = 1.0

const DOT_SCALE : float = 0.4
const FULL_SCALE : float = 1.0


onready var hbox_number: HBoxContainer = $Number
onready var lbl_decimal: ScrollingLabel = $Number/Decimal
onready var lbl_unit: ScrollingLabel = $Number/Unit
onready var lbl_plus: ScrollingLabel = $Number/Plus
onready var tween: Tween = $Tween


var _old_count: int = 0
var _hidden: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
    self.connect("item_rect_changed", self, "_on_Badge_item_rect_changed")
    setup()

func _get_property_list():
    return [
        {
            "class_name": "Badge",
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_CATEGORY,
            "name": "Badge",
            "type": TYPE_STRING
        },
        {
            "hint": PROPERTY_HINT_RANGE,
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "Content/count",
            "hint_string": "0, 99",
            "type": TYPE_INT
        },
        {
            "hint": PROPERTY_HINT_RANGE,
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "Content/overflow_count",
            "hint_string": "0, 99",
            "type": TYPE_INT
        },
        {
            "hint": PROPERTY_HINT_FLAGS,
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "Style/show_zero",
            "type": TYPE_BOOL
        },
        {
            "hint": PROPERTY_HINT_FLAGS,
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "Style/animated",
            "type": TYPE_BOOL
        },
        {
            "hint": PROPERTY_HINT_FLAGS,
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "Style/dot",
            "type": TYPE_BOOL
        },
        {
            "hint": PROPERTY_HINT_NONE,
            "usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_SCRIPT_VARIABLE,
            "name": "Style/color",
            "type": TYPE_COLOR
        },
        
    ]

func _set(property, value):
    match property:
        "Content/count": 
            set_count(value)
            return true
        "Content/overflow_count":
            set_overflow_count(value)
            return true
        "Style/show_zero":
            set_show_zero(value)
            return true
        "Style/animated":
            set_is_animated(value)
            return true
        "Style/dot":
            set_is_dot(value)
            return true
        "Style/color":
            set_color(value)
            return true

func _get(property):
    match property:
        "Content/count": 
            return get_count()
        "Content/overflow_count":
            return get_overflow_count()
        "Style/show_zero":
            return show_zero
        "Style/animated":
            return animated
        "Style/dot":
            return dot
        "Style/color":
            return color

func setup():
    if lbl_decimal == null: lbl_decimal = $Number/Decimal
    lbl_decimal.animated = animated
    if lbl_unit == null: lbl_unit = $Number/Unit
    lbl_unit.animated = animated
    if lbl_plus == null: lbl_plus = $Number/Plus
    lbl_plus.animated = animated

func set_count(_count: int) -> void:
    _old_count = count
    count = _count
    update_badge()

func get_count() -> int:
    return count

func set_overflow_count(_overflow_count: int) -> void:
    overflow_count = _overflow_count

func get_overflow_count() -> int:
    return overflow_count

func set_color(_color: Color) -> void:
    get("custom_styles/panel").bg_color = _color

func set_show_zero(_show_zero: bool) -> void:
    show_zero = _show_zero
    update_badge()

func set_is_animated(_animated: bool) -> void:
    animated = _animated

func set_is_dot(is_dot: bool) -> void:
    dot = is_dot
    badge_scale = DOT_SCALE if dot else FULL_SCALE
    update_badge()
    resize_badge()

func update_badge() -> void:
    if !is_inside_tree():
        return
    
    if hbox_number == null:
        hbox_number = $Number
    hbox_number.set_visible(!dot)
    
    if count < 0:
        return
    
    if (!show_zero and count == 0):
        set_show_badge(false)
        return
    
    set_show_badge(true)

    if lbl_plus == null: lbl_plus = $Number/Plus
    if lbl_unit == null: lbl_unit = $Number/Unit
    if lbl_decimal == null: lbl_decimal = $Number/Decimal
    
    var overflow: bool = count > overflow_count
    if overflow:
        if !lbl_plus.visible:
            lbl_plus.show()
            lbl_plus.move_to_index(1)
        emit_signal("overflow_reached")
        return
    
    if lbl_plus.visible and !lbl_plus.tween.is_active():
        lbl_plus.move_to_index(0)
        yield(lbl_plus.tween, "tween_all_completed")
        lbl_plus.hide()

    var _count: int = min(count, overflow_count)
    
    var split_count: PoolStringArray = split_count(_count)
    var split_old_count: PoolStringArray = split_count(_old_count)
    var unit: String = split_count[1]
    var decimal: String = split_count[0]
    
    lbl_unit.set_visible(unit != " ")
    lbl_decimal.set_visible(decimal != " ")
    
    if unit != split_old_count[1]:
        lbl_unit.move_to_index(int(unit))
    
    if decimal != split_old_count[0]:
        lbl_decimal.move_to_index(int(decimal))
    
    set_tooltip(str(_count))
    emit_signal("count_updated", _count)

func split_count(_count: int) -> PoolStringArray:
    var str_count: String = "%2d" % _count
    return PoolStringArray([str_count.substr(0,1), str_count.substr(1,2)])

func set_show_badge(show: bool) -> void:
    if !is_inside_tree():
        return 
    show_badge = show
    if show_badge:
        show_badge()
    else:
        hide_badge()
        
func hide_badge() -> void:
    if tween == null: tween = $Tween
    if !_hidden:
        _hidden = true
        resize_badge(0)

func show_badge() -> void:
    if tween == null: tween = $Tween
    if _hidden:
        _hidden = false
        resize_badge()

func resize_badge(target_scale: float = badge_scale) -> void:
    if !is_inside_tree():
        return 
    if animated:
            tween.interpolate_property(self, "rect_scale", self.rect_scale, Vector2(1,1) * target_scale, 0.3, Tween.TRANS_BACK, Tween.EASE_OUT)
            tween.start()  
    else:
        rect_scale = Vector2.ONE * target_scale

func _on_Badge_item_rect_changed():
    rect_pivot_offset = rect_size / 2
