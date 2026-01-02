extends Node

signal objective_completed(id, reward)

var objectives: Array = []

func add_objective(def: Dictionary):
 var o := def.duplicate(true)
 if not o.has("id"): o.id = str(objectives.size())
 if not o.has("status"): o.status = "pending"
 if not o.has("dependencies"): o.dependencies = []
 objectives.append(o)

func get_objective(id) -> Dictionary:
 for o in objectives:
  if o.id == id:
   return o
 return {}

func start(id):
 var o := get_objective(id)
 if o.is_empty():
  return
 if is_blocked(id):
  return
 o.status = "active"

func complete(id, reward := {}):
 var o := get_objective(id)
 if o.is_empty():
  return
 o.status = "completed"
 emit_signal("objective_completed", id, reward)

func fail(id):
 var o := get_objective(id)
 if o.is_empty():
  return
 o.status = "failed"

func is_blocked(id) -> bool:
 var o := get_objective(id)
 if o.is_empty():
  return true
 for dep in o.dependencies:
  var d := get_objective(dep)
  if d.is_empty() or d.status != "completed":
   return true
 return false

func all_completed() -> bool:
 for o in objectives:
  if o.status != "completed":
   return false
 return true
