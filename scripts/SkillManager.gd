extends Node

# Lista de habilidades y sus condiciones
# Skill list and conditions
var skills = {
	"dash": {
		"unlocked": false,
		"condition": "survive_3min",
		"progress": 0,
		"goal": 180
	},
	"wave": {
		"unlocked": false,
		"condition": "kill_20_pressure",
		"progress": 0,
		"goal": 20
	},
	"fire_snake": {
		"unlocked": false,
		"condition": "steal_from_boss",
		"progress": 0,
		"goal": 1
	},
}

func register_kill(type: String):
	# Registrar un kill y comprobar condiciones
	# Register a kill and check conditions
	if type == "pressure":
		skills["wave"]["progress"] += 1
		print("Kills con presión / Pressure kills: ", skills["wave"]["progress"], "/", skills["wave"]["goal"])
		if skills["wave"]["progress"] >= skills["wave"]["goal"]:
			unlock_skill("wave")

func unlock_skill(skill_name: String):
	# Desbloquear habilidad
	# Unlock skill
	if not skills[skill_name]["unlocked"]:
		skills[skill_name]["unlocked"] = true
		print("Habilidad desbloqueada / Skill unlocked: ", skill_name)
