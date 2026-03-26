extends Node

# Diccionario de habilidades, donde la key es el nombre de la skill
var skills: Dictionary = {}

# Señales para avisar cuando se activa o termina una habilidad
signal skill_used(skill_name: String)
signal skill_ready(skill_name: String)

func _ready():
	# Ejemplo: agregar algunas habilidades iniciales
	add_skill("dash", 2.0)       # cooldown 2s
	add_skill("fireball", 5.0)   # cooldown 5s

func add_skill(name: String, cooldown: float):
	skills[name] = {
		"cooldown": cooldown,
		"time_left": 0.0
	}

func use_skill(name: String) -> bool:
	if not skills.has(name):
		return false
	var skill = skills[name]
	if skill["time_left"] <= 0.0:
		skill["time_left"] = skill["cooldown"]
		emit_signal("skill_used", name)
		return true
	return false

func is_ready(name: String) -> bool:
	if not skills.has(name):
		return false
	return skills[name]["time_left"] <= 0.0

func _process(delta):
	for skill_name in skills.keys():
		if skills[skill_name]["time_left"] > 0.0:
			skills[skill_name]["time_left"] -= delta
			if skills[skill_name]["time_left"] <= 0.0:
				skills[skill_name]["time_left"] = 0.0
				emit_signal("skill_ready", skill_name)
