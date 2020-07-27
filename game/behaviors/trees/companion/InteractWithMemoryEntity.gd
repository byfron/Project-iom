extends "res://addons/godot-behavior-tree-plugin/action.gd"

func tick(tick: Tick) -> int:
	var actor = tick.actor
	var actor_entity = EntityPool.get(actor.entity_id)
	var context = tick.blackboard.get('context')
	var memory = tick.blackboard.get('memory')
	if memory.remembered_entity:
		#launch interaction and set entity to explored in memory map
		
		#EXPLORED
		memory.add_entity_memory(memory.remembered_entity.id, 1, GameEngine.DEFAULT_ENTMEM_CLEAN_TURNS)
		
		
		
		var criteria = []
		var lower_name = memory.remembered_entity.name.to_lower()
		criteria.append('object_' + lower_name)
		SignalManager.emit_signal("query_dialog_system", actor_entity, "onSee", criteria)
	
	#forget inmediate memory
		memory.remembered_entity = null
		
	return OK
