extends Node

class Memory:
	var value = 0
	var turns_left = 0

var memory_map = {}

#tile in attention
var remembered_pos = null

#entity in attention
var remembered_entity = null

#flag lost companion
var companion_gone = false

var last_seen_companion = null
	
#map of seen entities
var entities_visited = {}

#TODO: associate expiration times. Add interface for memory append/retrieve/expire
func add_memory(key, value, turns):
	var memory = Memory.new()
	memory.value = value
	memory.turns_left = turns
	memory_map[key] = memory

func add_entity_memory(entity_id, value, turns):
	var memory = Memory.new()
	memory.value = value
	memory.turns_left = turns
	entities_visited[entity_id] = memory

func is_entity_visited(entity_id):
	return entity_id in entities_visited

func update_memories():
	var memories_to_delete = []
	var ents_to_delete = []
	for mem in memory_map:
		var memory = memory_map[mem]
		memory.turns_left -= 1
		if memory.turns_left == 0:
			memories_to_delete.append(mem)
			
	for ent_mem in entities_visited:
		var ent_memory = entities_visited[ent_mem]
		ent_memory.turns_left -= 1
		if ent_memory.turns_left == 0:
			ents_to_delete.append(ent_mem)
			
	for mem in memories_to_delete:
		memory_map.erase(mem)
		
	for mem in ents_to_delete:
		entities_visited.erase(mem)

