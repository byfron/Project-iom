extends Node
var database = null

class Criterion:
	var query_key = ""
	func test(query):
		if query.has_key(query_key):
			return true
		return false

class IneqCriterion extends Criterion:
	func test(query):
		if '=' in query_key:
			var qksplit = query_key.split('=')
			var encoding_key = qksplit[0]
			
			var value = null
			if qksplit[1].is_valid_float():
				value = float(qksplit[1])
			elif qksplit[1] == "true":
				value = true
			elif qksplit[1] == "false":
				value = false
				
			if query.has_key(encoding_key):
				if query.encoding[encoding_key] == value:
					return true
			else:
				return false
			
		return false

class NotCriterion extends Criterion:
	func test(query):
		var fact = query_key.split('Not')[1]
		if query.has_key(fact):
			return false
		return true
		
class Response:
	var text_array = []
	var trigger_reply = ""
	
	#TODO: animations in the response to add dramatism!
	#(pointing and stuff)
	
	func get_response(idx):
		assert(idx < len(text_array))
		return text_array[idx]
	
	func get_random_response():
		var idx = randi()%len(text_array)
		return get_response(idx)

class Database:
	var rules = []
	var responses = {}
	
	func create_criterion(crit):
		if 'Not' in crit:
			return NotCriterion.new()
		if '=' in crit or '>' in crit or '<' in crit:
			return IneqCriterion.new()
			
		return Criterion.new()
	
	func compute_criteria_array(string_with_slashes):
		var crit_array = string_with_slashes.split('/')
		var criterions = []
		for crit in crit_array:
			crit = crit.strip_edges(true, true)
			
			#Instanciate different criterions acoording to the rule type
			#to virtualize the execution of the match
			var crit_obj = create_criterion(crit)
			crit_obj.query_key = crit
			criterions.append(crit_obj)
			
		return criterions
	
	func load_from_csv(csv_file):
		var file = CSVFile.new('#')
		file.load(csv_file)
		var headers = file.get_headers()
		var data = file.get_map()
		var idx_entry = 0
		for data_entry in data:
			
			if not data_entry:
				continue
			
			var rule = Rule.new()
			
			#TODO: check if a rule already exists with same
			#criteria and add the same response?
			rule.response = Response.new()
			rule.rule_id = file.map_get_value(data_entry, "ResponseID")
			var rule_text = file.map_get_value(data_entry, "ResponseText")
			rule.response.text_array.append(rule_text)
			rule.concept = file.map_get_value(data_entry, "Concept")
			rule.criterions = compute_criteria_array(file.map_get_value(data_entry, "Criteria"))
			
			rules.append(rule)
		
		#sort rules in descending score
		rules.sort_custom(self, "sort_by_cost")
	
	func run_query(query):
		var rule = match_rules(query)
		
		if rule:
			rule.update_memory_map(query.entity)
			return rule.response
			
		return null
		
	func compute_response(rule):
		var response = Response.new()
		response.create(rule)
		return response
	
	func match_rules(query):
		var matched_rules = []
		for rule in rules:
			if rule.match_rule(query):
				return rule
		
		return null
		
	func sort_by_cost(a, b):
		if len(a.criterions) > len(b.criterions):
			return true
		else:
			return false
		
class Rule:
	var rule_id = null
	var concept = null
	var criterions = []
	var facts_writeback = []
	var response = null
	
	func match_rule(query):
		
		if query.encoding['concept'] != concept:
			return false
		
		for criterion in criterions:
			if not criterion.test(query):
				return false
		return true
	
	func update_memory_map(entity):
		var memory = Utils.get_entity_memory(entity)
		#indicate that this sentence has been said already 1 time
		var said_rule_key = 'Said_' + rule_id
		if not (said_rule_key in memory.memory_map):
			memory.add_memory(said_rule_key, 1, GameEngine.DEFAULT_MEMORY_CLEAN_TURNS)
		else:
			var mem_value = memory.memory_map[said_rule_key].value
			memory.add_memory(said_rule_key, mem_value+1, GameEngine.DEFAULT_MEMORY_CLEAN_TURNS)
			
		#add the entity as visited in memory
		#memory.add_entity_memory(entity.id, 1, GameEngine.DEFAULT_ENTMEM_CLEAN_TURNS)

class Query:
	var entity = null
	var object_entity = null
	var encoding = {}
	
	func has_key(key):
		var testb = encoding.has(key)
		return encoding.has(key)
	
	func load_object_components(entity):
		for comp in entity.components:
			encoding['object_' + comp] = true
			
	func load_entity_components(entity):
		for comp in entity.components:
			encoding[comp] = true
			
	func load_entity_status(entity):
		encoding['health'] = 10
		encoding['mood'] = 3
		
	func load_entity_memory(entity):
		#Go through memory and append all the
		#stuff that has been already said to the encoding
		var memory = Utils.get_entity_memory(entity)
		for m in memory.memory_map:
			encoding[m] = memory.memory_map[m]
		
	func load_world_status():
		pass

	func process_criteria(crit):
		var name_value = null
		if '=' in crit:
			name_value = crit.split('=')
			name_value[1] = '=' + name_value[1]
		elif '>' in crit:
			name_value = crit.split('>')
			name_value[1] = '>' + name_value[1]
		elif '<' in crit:
			name_value = crit.split('<')
			name_value[1] = '<' + name_value[1]
		else:
			return [crit]
			
		return name_value
			
	func compile(entity_, concept, criterions, object_entity_ = null):
		entity = entity_
		object_entity = object_entity_
		
		if object_entity:
			load_object_components(object_entity)
			
		load_entity_components(entity)
		load_entity_status(entity)
		load_entity_memory(entity)
		load_world_status()
		
		encoding['who'] = entity.name
		encoding['concept'] = concept
		
		for crit in criterions:
			var name_value = process_criteria(crit)
			if len(name_value) == 1:
				encoding[name_value[0]] = true
			else:
				encoding[name_value[0]] = name_value[1]
	
func create_database(csv_file):
	database = Database.new()
	database.load_from_csv(csv_file)
	
func process_query(entity, concept, criteria_list, object_entity_id=null):
	var query = Query.new()
	query.compile(entity, concept, criteria_list, object_entity_id)
	var response = database.run_query(query)
	if response:
		SignalManager.emit_signal('send_action', ActionFactory.create_say_something_action(entity, response))
