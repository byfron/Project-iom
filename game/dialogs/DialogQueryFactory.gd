extends Node
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func makeQuery(entity, concept):
	var query = Query.new()
	query.who = entity.name
	query.concept = concept
	
	#get all state of entity in the query
	query.load_entity_status(entity)
	query.compile()
