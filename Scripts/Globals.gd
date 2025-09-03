extends Node

static func combinationsAggregate(items: Array, r: int) -> Array[Vector4i]:
	var n := items.size()
	if r < 0 or r > n:
		return []
	var result = []
	_combine_rec(items, 0, r, [], result)
	var final: Array[Vector4i] = []
	for array in result:
		var sum
		for vec in array: 
			if sum == null: sum = vec
			else: sum += vec
		final.append(sum)
	return final

static func _combine_rec(items: Array, start: int, r: int, curr: Array, out: Array) -> void:
	if r == 0:
		out.append(curr.duplicate())
		return
	var last_start := items.size() - r
	for i in range(start, last_start + 1):
		curr.append(items[i])
		_combine_rec(items, i + 1, r - 1, curr, out)
		curr.pop_back()


static func instanceSceneAtCoord(coord, parent, scene):
	var instance = scene.instantiate()
	if instance is Node2D or instance is Control:
		instance.position = coord
	parent.add_child(instance)
	return instance
