class_name SGF
extends Node

const LOG_LEVEL := 1

class SgfNode:
	var parent: SgfNode
	var children: Array[SgfNode] = []
	var properties: Dictionary[String, Variant] = {}
	
	func _init(parent_: SgfNode) -> void:
		parent = parent_
		if parent:
			parent.children.append(self)
	
	func assign_prop(key: String, values: Array[String]) -> void:
		if SgfTypes.PROP_TYPES.has(key):
			properties[key] = SgfTypes.PROP_TYPES[key].call(values)
		elif LOG_LEVEL > 0:
			print("Unknown property: ", key, values)
	
	func build_tree() -> Array[SgfNode]:
		var tree: Array[SgfNode] = [self]
		var top: SgfNode = self
		while top.parent != null:
			top = top.parent
			tree.append(top)
		
		tree.reverse()
		return tree
	
	func left_leaf() -> SgfNode:
		if children:
			return children[0].left_leaf()
		return self
	
	func next_crossroad() -> SgfNode:
		if children:
			if len(children[0].children) == 1:
				return children[0].next_crossroad()
			return children[0]
		return self
	
	func prev_crossroad() -> SgfNode:
		if parent:
			if len(parent.children) <= 1:
				return parent.prev_crossroad()
			return parent
		return self
	
	const TEXT_REPR: Dictionary[String, String] = {
		"BM": "Bad move",
		"DO": "Doubtful move",
		"IT": "Interesting move",
		"TE": "Good move",
		"DM": "Even",
		"GB": "Good for Black",
		"GW": "Good for White",
		"HO": "Interesting/Decisive",
		"V": "Value: ",
		"N": "Name: ",
	}
	
	func get_evaluation() -> String:
		var s := ""
		for i in TEXT_REPR:
			if i in properties:
				if properties[i] is SgfTypes.SgfDouble:
					if properties[i].value == 2:
						s += "Very "

				s += TEXT_REPR[i]

				if properties[i] is SgfTypes.SgfReal:
					s += "%f" % properties[i].value
				if properties[i] is SgfTypes.SgfText:
					s += properties[i].value
				
				s += ", "
		
		if s:
			s = s.substr(0, len(s)-2)
		
		return s
	
	func serialize() -> String:
		var s := ""
		s += ";"
		for i in properties:
			s += i + str(properties[i])
		
		if children:
			if len(children) == 1:
				s += children[0].serialize()
			else:
				for i in children:
					s += "(" + i.serialize() + ")"
		
		if parent:
			return s
		
		return "(" + s + ")"
	
	func remove_from_tree():
		if not parent:
			return
		
		parent.children.remove_at(parent.children.find(self))
		parent = null

class SgfFile:
	const WHITESPACE = " \n\r\t"
	const SPECIAL = "();"
	
	
	var text: String
	var loc: int = 0
	
	var stack: Array[SgfNode] = [null]
	var roots: Array[SgfNode] = []
	
	func _init(text_: String) -> void:
		text = text_
		parse()
	
	static func create_empty(size: Vector2i) -> SgfFile:
		return SgfFile.new("(;FF[4] SZ[%s])" % (str(size.x) if size.x == size.y else "%d:%d" % [size.x, size.y]))
	
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
		if LOG_LEVEL > 1 and node.properties.has(key.strip_edges()):
			print(key.strip_edges(),str(node.properties[key.strip_edges()]))
		return !node_ended
	
	func parse() -> void:
		var top: SgfNode = null
		while available():
			var c = consume()
			if c == "(":
				stack.push_back(top)
			elif c == ")":
				top = stack.pop_back()
				#top = stack.back()
			elif c == ";":
				if LOG_LEVEL > 1:
					print("-------------", top)
				var n = SgfNode.new(top)
				if top == null and len(stack) == 2:
					roots.append(n)
				top = n
				while available():
					if not parse_prop(n):
						break
		pass
	
	func serialize() -> String:
		var s := ""
		for i in roots:
			s += i.serialize()
		return s
