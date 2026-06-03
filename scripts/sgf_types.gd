class_name SgfTypes

static var PROP_TYPES: Dictionary[String, Callable] = {
# Move props
	"B": SgfPoint.new,
	"KO": SgfNone.new, # NOTE: KO is in the FF[4] docs but KM is in the example and on wikipedia
	"KM": SgfNone.new,
	"MN": SgfNumber.new,
	"W": SgfPoint.new,
	
	# Setup props
	"AB": list_of.bind(SgfPoint.new),
	"AE": list_of.bind(SgfPoint.new),
	"AW": list_of.bind(SgfPoint.new),
	"PL": SgfColor.new,
	
	# Node annotation props
	"C": SgfText.new,
	"DM": SgfDouble.new,
	"GB": SgfDouble.new,
	"GW": SgfDouble.new,
	"HO": SgfDouble.new,
	"N": SgfText.new,
	"UC": SgfDouble.new,
	"V": SgfReal.new,
	
	# Move annotation props
	"BM": SgfDouble.new,
	"DO": SgfNone.new,
	"IT": SgfNone.new,
	"TE": SgfDouble.new,
	
	# Markup props
	"AR": list_of.bind(composed_of.bind(SgfPoint.new, SgfPoint.new)),
	"CR": list_of.bind(SgfPoint.new),
	"DD": elist_of.bind(SgfPoint.new),
	"LB": list_of.bind(composed_of.bind(SgfPoint.new, SgfText.new)),
	"LN": list_of.bind(composed_of.bind(SgfPoint.new, SgfPoint.new)),
	"MA": list_of.bind(SgfPoint.new),
	"SQ": list_of.bind(SgfPoint.new),
	"TR": list_of.bind(SgfPoint.new), # NOTE: TW, TB
	
	# Root props
	"AP": composed_of.bind(SgfText.new, SgfText.new),
	"CA": SgfText.new,
	"FF": SgfNumber.new,
	"GM": SgfNumber.new,
	"ST": SgfNumber.new,
	"SZ": composed_of.bind(SgfNumber.new, SgfNumber.new),
	
	# Game info props
	"AN": SgfText.new,
	"BR": SgfText.new,
	"BT": SgfText.new,
	"CP": SgfText.new,
	"DT": SgfText.new,
	"EV": SgfText.new,
	"GC": SgfText.new,
	"GN": SgfText.new,
	"ON": SgfText.new,
	"OT": SgfText.new,
	"PB": SgfText.new,
	"PC": SgfText.new,
	"PW": SgfText.new,
	"RE": SgfText.new,
	"RO": SgfText.new,
	"RU": SgfText.new,
	"SO": SgfText.new,
	"TM": SgfReal.new,
	"US": SgfText.new,
	"WR": SgfText.new,
	"WT": SgfText.new,
	
	# Timing props
	"BL": SgfReal.new,
	"OB": SgfNumber.new,
	"OW": SgfNumber.new,
	"WL": SgfReal.new,
	
	# Misc props
	"FG": composed_of.bind(SgfNumber.new, SgfText.new),
	"PM": SgfNumber.new,
	"VW": elist_of.bind(SgfPoint.new),
}

class SgfTypeBase:
	func _init(_texts: Array[String]) -> void:
		pass

class SgfNone extends SgfTypeBase:
	func _to_string() -> String:
		return "[]"

class SgfDouble extends SgfTypeBase:
	var value := 0
	func _init(texts: Array[String]) -> void:
		assert(len(texts) == 1)
		if texts[0] == "1":
			value = 1
		elif texts[0] == "2":
			value = 2
		else:
			push_error("Invalid double: %s" % texts[0])
	
	func _to_string() -> String:
		return "[%d]" % value

class SgfColor extends SgfTypeBase:
	const WHITE = 1
	const BLACK = 2
	
	var value := 0
	func _init(texts: Array[String]) -> void:
		assert(len(texts) == 1)
		if texts[0] == "W":
			value = WHITE
		elif texts[0] == "B":
			value = BLACK
		else:
			push_error("Invalid color: %s" % texts[0])
	
	func _to_string() -> String:
		return "[W]" if value == WHITE else "[B]"

class SgfPoint extends SgfTypeBase:
	# 1-indexed
	var x := 0
	var y := 0
	var x2 := 0
	var y2 := 0
	var passed := false
	
	func _init(texts: Array[String]) -> void:
		assert(len(texts) == 1)
		if len(texts[0]) == 0:
			# pass
			x = -1
			y = -1
		elif len(texts[0]) == 2:
			x = texts[0].unicode_at(0)-ord('a')+1
			y = texts[0].unicode_at(1)-ord('a')+1
		elif len(texts[0]) == 4:
			x = texts[0].unicode_at(0)-ord('a')+1
			y = texts[0].unicode_at(1)-ord('a')+1
			x2 = texts[0].unicode_at(3)-ord('a')+1
			y2 = texts[0].unicode_at(4)-ord('a')+1
	
	func get_moves() -> Array[Variant]:
		if passed:
			return []
		
		if x2 and y2:
			return []
		
		return [Vector2i(x,y)]
	
	func dump() -> String:
		return String.chr(ord('a')+x-1)+String.chr(ord('a')+y-1)

class SgfNumber extends SgfTypeBase:
	var value := 0
	func _init(texts: Array[String]) -> void:
		assert(len(texts) == 1)
		value = int(texts[0])
	
	func dump() -> String:
		return "%d" % value

class SgfReal extends SgfTypeBase:
	var value := 0.0
	func _init(texts: Array[String]) -> void:
		assert(len(texts) == 1)
		value = float(texts[0])
	
	func dump() -> String:
		return "%f" % value

class SgfText extends SgfTypeBase:
	var value := ""
	func _init(texts: Array[String]) -> void:
		assert(len(texts) == 1)
		value = texts[0]
	
	func dump() -> String:
		return "%s" % value

static func list_of(texts: Array[String], sgf_type: Callable) -> Array:
	var values = []
	for i in texts:
		values.append(sgf_type.call(_str_arr_cast([i])))
	return values

static func elist_of(texts: Array[String], sgf_type: Callable) -> Array:
	var values = []
	if not texts[0].strip_edges():
		return []
	for i in texts:
		values.append(sgf_type.call(_str_arr_cast([i])))
	return values

static var _compose_regex = RegEx.new()

static func _regex_split(subject: String, regex: RegEx) -> Array[String]:
	var results: Array[String] = []	
	var last_index = 0
	
	for item in regex.search_all(subject):
		results.append(subject.substr(last_index, item.get_start() - last_index))
		last_index = item.get_end()
	
	results.append(subject.substr(last_index))
	
	return results

static func _str_arr_cast(arr: Array) -> Array[String]:
	var typed: Array[String] = []
	typed.assign(arr)
	return typed

static func composed_of(texts: Array[String], left_type: Callable, right_type: Callable) -> Array:
	if not _compose_regex.is_valid():
		_compose_regex.compile("(?<!\\\\):")
	assert(len(texts) == 1)
	var sides := _regex_split(texts[0], _compose_regex)
	assert(len(sides) > 0 && len(sides) < 3)
	var values = []
	values.append(left_type.call(_str_arr_cast([sides[0]])))
	if len(sides) == 2:
		values.append(right_type.call(_str_arr_cast([sides[1]])))
	return values
