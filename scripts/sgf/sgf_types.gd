class_name SgfTypes

static var PROP_TYPES: Dictionary[String, Callable] = {
	# Move props
	"B": SgfPoint.new,                      # Black move
	"KO": SgfNone.new,                      # Execute move even if illegal (e.g., Ko violation)
	"MN": SgfNumber.new,                    # Set move number
	"W": SgfPoint.new,                      # White move
	
	# Setup props
	"AB": SgfPointList.new,                 # Add Black stones
	"AE": SgfPointList.new,                 # Add Empty (clear points)
	"AW": SgfPointList.new,                 # Add White stones
	"PL": SgfColor.new,                     # Player whose turn it is to play
	
	# Node annotation props
	"C": SgfText.new,                       # Comment text
	"DM": SgfDouble.new,                    # Position is even (even result for both)
	"GB": SgfDouble.new,                    # Good for Black
	"GW": SgfDouble.new,                    # Good for White
	"HO": SgfDouble.new,                    # Hotspot (interesting/decisive position)
	"N": SgfText.new,                       # Node name
	"UC": SgfDouble.new,                    # Position is unclear
	"V": SgfReal.new,                       # Node value (estimated score; positive for B, negative for W)
	
	# Move annotation props
	"BM": SgfDouble.new,                    # Bad move
	"DO": SgfNone.new,                      # Doubtful move
	"IT": SgfNone.new,                      # Interesting move
	"TE": SgfDouble.new,                    # Tesuji (good move)
	
	# Markup props
	"AR": SgfList.new.bind(SgfCompose.new.bind(SgfPoint.new, SgfPoint.new)), # Draw arrow
	"CR": SgfPointList.new,                 # Circle markup
	"DD": SgfPointList.new.bind(true),      # Dim/grey out points
	"LB": SgfList.new.bind(SgfCompose.new.bind(SgfPoint.new, SgfText.new)),  # Text label on board
	"LN": SgfList.new.bind(SgfCompose.new.bind(SgfPoint.new, SgfPoint.new)), # Draw line
	"MA": SgfPointList.new,                 # Mark with 'X'
	"SL": SgfPointList.new,                 # Selected points
	"SQ": SgfPointList.new,                 # Square markup
	"TR": SgfPointList.new,                 # Triangle markup
	
	# Root props
	"AP": SgfCompose.new.bind(SgfText.new, SgfText.new), # Application name and version
	"CA": SgfText.new,                      # Charset/encoding used for text
	"FF": SgfNumber.new,                    # File format version
	"GM": SgfNumber.new,                    # Game type (e.g., 1 = Go, 2 = Othello, 3 = Chess)
	"ST": SgfNumber.new,                    # Style of variation display
	"SZ": SgfCompose.new.bind(SgfNumber.new, SgfNumber.new), # Board size
	
	# Game info props
	"AN": SgfText.new,                      # Name of person who annotated the game
	"BR": SgfText.new,                      # Black rank
	"BT": SgfText.new,                      # Black team name
	"CP": SgfText.new,                      # Copyright info
	"DT": SgfText.new,                      # Date when game was played
	"EV": SgfText.new,                      # Event/tournament name
	"GC": SgfText.new,                      # Game commentary/background summary
	"GN": SgfText.new,                      # Game name
	"ON": SgfText.new,                      # Opening info (e.g., fuseki pattern)
	"OT": SgfText.new,                      # Overtime (byo-yomi) method description
	"PB": SgfText.new,                      # Player Black name
	"PC": SgfText.new,                      # Place where game was played
	"PW": SgfText.new,                      # Player White name
	"RE": SgfText.new,                      # Result of the game
	"RO": SgfText.new,                      # Round number and type
	"RU": SgfText.new,                      # Ruleset name (e.g., Japanese, AGA)
	"SO": SgfText.new,                      # Source of the game record (e.g., book, journal)
	"TM": SgfReal.new,                      # Time limit in seconds
	"US": SgfText.new,                      # User/program name that entered the game record
	"WR": SgfText.new,                      # White rank
	"WT": SgfText.new,                      # White team name
	
	# Timing props
	"BL": SgfReal.new,                      # Black time left (seconds)
	"OB": SgfNumber.new,                    # Overtime stones left to play for Black
	"OW": SgfNumber.new,                    # Overtime stones left to play for White
	"WL": SgfReal.new,                      # White time left (seconds)
	
	# Misc props
	"FG": SgfCompose.new.bind(SgfNumber.new, SgfText.new), # Figure property (for printing diagrams)
	"PM": SgfNumber.new,                    # Print move numbers style
	"VW": SgfPointList.new.bind(true),      # View only part of the board
	
	# Go specific
	"HA": SgfNumber.new,                    # Handicap
	"KM": SgfReal.new,                      # Komi
	"TB": SgfPointList.new.bind(true),      # Black territory
	"TW": SgfPointList.new.bind(true),      # White territory
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
	var value := Stone.StoneColor.NONE
	func _init(texts: Array[String]) -> void:
		assert(len(texts) == 1)
		if texts[0] == "W":
			value = Stone.StoneColor.WHITE
		elif texts[0] == "B":
			value = Stone.StoneColor.BLACK
		else:
			push_error("Invalid color: %s" % texts[0])
	
	func _to_string() -> String:
		return "[W]" if value == Stone.StoneColor.WHITE else "[B]"

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

	func to_ivec() -> Vector2i:
		return Vector2i(x,y)

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

static func _prop_trim(s: String) -> String:
	return s.substr(1, s.length() - 2)

class SgfCompose extends SgfTypeBase:
	var left_value: Variant = null
	var right_value: Variant = null
	
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
			return "[%s:%s]" % [SgfTypes._prop_trim(str(left_value)), SgfTypes._prop_trim(str(right_value))]
		return str(left_value)
	
	static var _compose_regex = RegEx.new()
	static func _regex_split(subject: String, regex: RegEx) -> Array[String]:
		var results: Array[String] = []	
		var last_index = 0
		
		for item in regex.search_all(subject):
			results.append(subject.substr(last_index, item.get_start() - last_index))
			last_index = item.get_end()
		
		results.append(subject.substr(last_index))
		
		return results
