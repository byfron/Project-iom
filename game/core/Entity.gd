var id = null 
var name = ''
var components = {}
	
func _init(id, name):
	self.id = id
	self.name = name
	EntityPool.eindex[self.id] = self
		
func attach(type, component):
	components[type] = component
	if not (type in EntityPool.cindex):
			EntityPool.cindex[type] = []
	EntityPool.cindex[type].append(self)

func remove(type):
	components.erase(type)