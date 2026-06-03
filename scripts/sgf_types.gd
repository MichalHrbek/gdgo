class_name SgfTypes

static var PROP_TYPES: Dictionary[String, Callable] = {
# Move props
	"B": SgfPoint.new,
	"KO": SgfNone.new, # NOTE: KO is in the FF[4] docs but KM is in the example and on wikipedia
	"KM": SgfNone.new,
	"MN": SgfNumber.new,
	"W": SgfPoint.new,
	
	# Setup props
	"AB": SgfPointList.new,
	"AE": SgfPointList.new,
	"AW": SgfPointList.new,
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
	"AR": SgfList.new.bind(SgfCompose.new.bind(SgfPoint.new, SgfPoint.new)),
	"CR": SgfPointList.new,
	"DD": SgfPointList.new.bind(true),
	"LB": SgfList.new.bind(SgfCompose.new.bind(SgfPoint.new, SgfText.new)),
	"LN": SgfList.new.bind(SgfCompose.new.bind(SgfPoint.new, SgfPoint.new)),
	"MA": SgfPointList.new,
	"SQ": SgfPointList.new,
	"TR": SgfPointList.new, # NOTE: TW, TB
	
	# Root props
	"AP": SgfCompose.new.bind(SgfText.new, SgfText.new),
	"CA": SgfText.new,
	"FF": SgfNumber.new,
	"GM": SgfNumber.new,
	"ST": SgfNumber.new,
	"SZ": SgfCompose.new.bind(SgfNumber.new, SgfNumber.new),
	
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
	"FG": SgfCompose.new.bind(SgfNumber.new, SgfText.new),
	"PM": SgfNumber.new,
	"VW": SgfPointList.new.bind(true),
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
	
	static func chr_to_int(c: String) -> int:
		return c.unicode_at(0)-ord('a')+1
	
	static func int_to_chr(n: int) -> String:
		return String.chr(ord('a')+n-1)
	
	func _init(texts: Array[String]) -> void:
		assert(len(texts) == 1)
		if len(texts[0]) == 2:
			x = texts[0].unicode_at(0)-ord('a')+1
			y = texts[0].unicode_at(1)-ord('a')+1
		else:
			assert(len(texts[0]) == 0) # Pass
	
	func _to_string() -> String:
		if x and y:
			return "[" + int_to_chr(x) + int_to_chr(y) + "]"
		return "[]"

class SgfPointList extends SgfTypeBase:
	var points: Array[Vector2i] = []
	
	func _init(texts: Array[String], elist: bool = false) -> void:
		if elist:
			if len(texts) == 1:
				if len(texts[0]) == 0:
					return
		
		for i in texts:
			assert(len(i) == 2 or len(i) == 5)
			if len(i) == 2:
				points.append(Vector2i(SgfPoint.chr_to_int(i[0]), SgfPoint.chr_to_int(i[1])))
			else:
				var x1 := SgfPoint.chr_to_int(i[0])
				var y1 := SgfPoint.chr_to_int(i[1])
				var x2 := SgfPoint.chr_to_int(i[3])
				var y2 := SgfPoint.chr_to_int(i[4])
				
				for x in range(x1, x2+1):
					for y in range(y1, y2+1):
						points.append(Vector2i(x,y))
	
	func _to_string() -> String:
		if not points:
			return "[]"
		
		var s := ""
		for i in points:
			s += "[" + SgfPoint.int_to_chr(i.x) + SgfPoint.int_to_chr(i.y) + "]"
		return s

class SgfNumber extends SgfTypeBase:
	var value := 0
	func _init(texts: Array[String]) -> void:
		assert(len(texts) == 1)
		value = int(texts[0])
	
	func _to_string() -> String:
		return "[%d]" % value

class SgfReal extends SgfTypeBase:
	var value := 0.0
	func _init(texts: Array[String]) -> void:
		assert(len(texts) == 1)
		value = float(texts[0])
	
	func _to_string() -> String:
		return "[%f]" % value

class SgfText extends SgfTypeBase:
	var value := ""
	func _init(texts: Array[String]) -> void:
		assert(len(texts) == 1)
		value = texts[0]
	
	func _to_string() -> String:
		return "[%s]" % value

class SgfList extends SgfTypeBase:
	var values: Array[Variant] = []
	
	func _init(texts: Array[String], sgf_type: Callable, elist: bool = false) -> void:
		if elist:
			if len(texts) == 1:
				if len(texts[0]) == 0:
					return
		
		for i in texts:
			values.append(sgf_type.call(SgfTypes._str_arr_cast([i])))
	
	func _to_string() -> String:
		if not values:
			return "[]"
		
		var s := ""
		for i in values:
			s += str(i)
		return s

static func _str_arr_cast(arr: Array) -> Array[String]:
	var typed: Array[String] = []
	typed.assign(arr)
	return typed

class SgfCompose extends SgfTypeBase:
	var left_value: Variant
	var right_value: Variant
	
	func _init(texts: Array[String], left_type: Callable, right_type: Callable) -> void:
		assert(len(texts) == 1)
		
		if not SgfCompose._compose_regex.is_valid():
			SgfCompose._compose_regex.compile("(?<!\\\\):")
		
		var sides := _regex_split(texts[0], _compose_regex)
		assert(len(sides) > 0 && len(sides) < 3)
		
		
		left_value = left_type.call(SgfTypes._str_arr_cast([sides[0]]))
		if len(sides) == 2:
			right_value = right_type.call(SgfTypes._str_arr_cast([sides[1]]))
	
	func _to_string() -> String:
		if right_value:
			return "[%s:%s]" % [left_value, right_value]
		return "[%s]" % left_value
	
	static var _compose_regex = RegEx.new()
	static func _regex_split(subject: String, regex: RegEx) -> Array[String]:
		var results: Array[String] = []	
		var last_index = 0
		
		for item in regex.search_all(subject):
			results.append(subject.substr(last_index, item.get_start() - last_index))
			last_index = item.get_end()
		
		results.append(subject.substr(last_index))
		
		return results
