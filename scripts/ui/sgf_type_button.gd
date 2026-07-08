class_name SgfTypeButton
extends OptionButton

@export_enum("L1:0", "L2(List):1", "L3(Compose):2") var type: int = 0

@export var left_compose: SgfTypeButton
@export var right_compose: SgfTypeButton
@export var list: SgfTypeButton

var types = []
var should_select: Variant
var is_ready := false

func _ready() -> void:
	if is_ready:
		return
	is_ready = true
	
	if type == 0:
		types.append_array(SgfTypes.TYPES_L1)
		types.append_array(SgfTypes.TYPES_L2)
		types.append_array(SgfTypes.TYPES_L3)
	elif type == 1:
		types.append_array(SgfTypes.TYPES_L2)
		types.append_array(SgfTypes.TYPES_L3)
	elif type == 2:
		types.append_array(SgfTypes.TYPES_L3)
	
	for i in types:
		add_item(i.generic_typename())
	
	if should_select:
		select(types.find(should_select))
	else:
		select(types.find(SgfTypes.SgfNone))
	if type == 0:
		_on_update()
	item_selected.connect(_on_update.unbind(1))

func _on_update() -> void:
	_ready()
	
	if selected == -1:
		return
	
	if types[selected] == SgfTypes.SgfList:
		list._on_update()
		list.show()
		left_compose.visible = list.selected != -1 and list.types[list.selected] == SgfTypes.SgfCompose
		right_compose.visible = list.selected != -1 and list.types[list.selected] == SgfTypes.SgfCompose
	elif types[selected] == SgfTypes.SgfCompose:
		left_compose._on_update()
		right_compose._on_update()
		if list: list.hide()
		left_compose.show()
		right_compose.show()
	else:
		if list: list.hide()
		if left_compose: left_compose.hide()
		if right_compose: right_compose.hide()

func get_type() -> Callable:
	if types[selected] == SgfTypes.SgfList:
		return SgfTypes.SgfList.new.bind(list.get_type())
	elif types[selected] == SgfTypes.SgfCompose:
		return SgfTypes.SgfCompose.new.bind(left_compose.get_type(), right_compose.get_type())
	else:
		return types[selected].new
