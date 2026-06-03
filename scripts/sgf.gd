class_name SGF
extends Node

func _ready() -> void:
	#var s := SgfFile.new("(;FF[4]GM[1]SZ[19];B[aa];W[bb];B[cc];W[dd];B[ad];W[bd])")
	var s := SgfFile.new(FileAccess.open("res://examples/ff4_ex.sgf.txt", FileAccess.READ).get_as_text())
	s.parse()
	print(s.roots)
	print(len(s.roots))

class SgfNode:
	var parent: SgfNode
	var children: Array[SgfNode]
	var properties: Dictionary[String, Variant]
	
	func _init(parent_: SgfNode) -> void:
		parent = parent_
		if parent:
			parent.children.append(self)
	
	func assign_prop(key: String, values: Array[String]) -> void:
		#print(key, values)
		if SgfTypes.PROP_TYPES.has(key):
			properties[key] = SgfTypes.PROP_TYPES[key].call(values)
		else:
			pass
			#print("^^ unknown key")

class SgfFile:
	const WHITESPACE = " \n\r\t"
	const SPECIAL = "();"
	
	var text: String
	var loc: int = 0
	
	var stack: Array[SgfNode] = [null]
	var roots = []
	
	func _init(text_: String) -> void:
		text = text_
	
	func peek() -> String:
		return text[loc]
	
	func consume() -> String:
		if loc == text.length():
			return ""
		loc += 1
		return text[loc-1]
	
	func available() -> int:
		return text.length()-loc
	
	func parse_prop(node: SgfNode) -> bool:
		var key = ""
		var values: Array[String] = []
		
		while available():
			if peek() in SPECIAL:
				return false
			if peek() == "[":
				consume()
				break
			key += consume()
	

		var value = ""
		var node_ended = false
		var prop_ended = false
		while available():
			if peek() == "]":
				values.append(value.strip_edges())
				value = ""
				consume()
				while available():
					if peek() == "[":
						consume()
						break
					if peek() in WHITESPACE:
						consume()
						continue
					if peek() in SPECIAL:
						node_ended = true
					else:
						prop_ended = true
					break
				
				if node_ended or prop_ended:
					break
			elif peek() == "\\":
				value += consume() + consume()
			else:
				value += consume()
		
		node.assign_prop(key.strip_edges(), values)
		return !node_ended
	
	func parse() -> void:
		var top: SgfNode = null
		var index := 0
		while available():
			var c = consume()
			if c == "(":
				stack.push_back(top)
			elif c == ")":
				stack.pop_back()
				top = stack.back()
			elif c == ";":
				var n = SgfNode.new(top)
				index += 1
				#print(index)
				if top == null and len(stack) == 2:
					roots.append(n)
				top = n
				while available():
					if not parse_prop(n):
						break
		pass
