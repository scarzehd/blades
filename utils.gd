class_name Utils

static func pick_random_weighted(values:Array, weights:Array[float]):
	assert(values.size() == weights.size(), "There must be one weight for each possible value")
	var r = randf_range(0, weights.reduce(func(value, total): return value + total, 0))
	for i in range(values.size()):
		r -= weights[i]
		if r <= 0:
			return values[i]
	
	return values[values.size() - 1]
