func astar(grid, start_idxv, end_idxv):
	var pq = preload("pq.gd").new()
	pq.make()
	var traversed = {}	
	var result = _evaluate_grid_samethread(pq, traversed, grid, start_idxv.x, start_idxv.y, 
		start_idxv.x, start_idxv.y, end_idxv.x, end_idxv.y)
	return result
	

func _distance(a, b):
	
	return a.distance_to(b)
	
	var ab_x = abs(b.x-a.x)
	var ab_y = abs(b.y-a.y)
	return min(ab_x, ab_y)
	
func _grid_traverse_queue(pq, traversed, grid, curr, prev, to, curr_cost):

	if grid.has(curr):
		return
	
	#if curr in grid:
	#	return
	
	#if grid[curr].has('traversable'):
	#	if grid[curr]['traversable'] == false:
	#		return
	
	var gx = curr_cost + _distance(prev, curr)
	var hx = _distance(curr, to) 
	var curr_weight = -(gx+hx)
	
	## Weights could never be lower, because of priority_queue
	var already_visited = traversed.has(curr) # || (traversed[curr] != null && traversed[curr].weight > curr_weight)
	
	if already_visited:
		return
		
	traversed[curr] = {
		curr = curr,
		prev = prev,
		weight = -gx,
		accum_cost = gx
	}
	
	pq.push({
		curr = curr,
		prev = prev,
		pqval = -gx,
		accum_cost = gx
	})
	
	return 
	
func _evaluate_grid_samethread(pq, traversed, grid, i, j, start_i, start_j, end_i, end_j):
	return _evaluate_grid( 
		[{
			pq = pq, 
			traversed = traversed, 
			grid = grid, 
			i = i,
			j = j,
			start_i = start_i,
			start_j = start_j,
			end_i = end_i,
			end_j = end_j,
			curr_cost = 0
		}])

func _evaluate_grid(userdata):
	var pq = userdata[0].pq
	var traversed = userdata[0].traversed
	var grid = userdata[0].grid
	var start_i = userdata[0].start_i
	var start_j = userdata[0].start_j
	
	var current_probe = 0
	var maximum_probe = 200
	var end_i = userdata[0].end_i
	var end_j = userdata[0].end_j
		
	## TCO
	while true:
		var i = userdata[0].i
		var j = userdata[0].j
		var curr_cost = userdata[0].curr_cost

		var curr = Vector2(i, j)
		var end = Vector2(end_i, end_j)
		
		#TODO: we don't need to compute this (we can store it in the node)
		#var curr_cost = current_probe#_distance(Vector2(start_i, start_j), Vector2(i,j))
		
		_grid_traverse_queue(pq, traversed, grid, Vector2(i-1,j), curr, end, curr_cost)
		_grid_traverse_queue(pq, traversed, grid, Vector2(i+1,j), curr, end, curr_cost)
		_grid_traverse_queue(pq, traversed, grid, Vector2(i,j-1), curr, end, curr_cost)
		_grid_traverse_queue(pq, traversed, grid, Vector2(i,j+1), curr, end, curr_cost)
		
		_grid_traverse_queue(pq, traversed, grid, Vector2(i-1,j-1), curr, end, curr_cost)
		_grid_traverse_queue(pq, traversed, grid, Vector2(i-1,j+1), curr, end, curr_cost)
		_grid_traverse_queue(pq, traversed, grid, Vector2(i+1,j+1), curr, end, curr_cost)
		_grid_traverse_queue(pq, traversed, grid, Vector2(i+1,j-1), curr, end, curr_cost)
		
		if pq.empty():
			return []
			
		var top = pq.top()
		pq.pop()
		current_probe += 1
		
		
		if i == end_i and j == end_j:
			var result = []
			var start = Vector2(start_i, start_j)
			var begin = Vector2(end.x, end.y)
			_get_path(grid, traversed, start, end, begin, result)
			return result
		elif current_probe > maximum_probe:
			return []
		else:			
			userdata[0].i = top.curr.x
			userdata[0].j = top.curr.y
			userdata[0].curr_cost = top.accum_cost

func _get_path(grid, traversed, start, end, curr, result):
	while true:
		if curr == start:
			result.push_front(curr)
			return
		result.push_front(curr)
		curr = traversed[curr].prev
