extends CanvasLayer

# ID y nombre de la habilidad
# Skill ID and name
var skill_id: String = ""
var skill_display_name: String = ""

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true
	# Buscar nodos directamente
	# Find nodes directly
	var skill_label = find_child("SkillLabel")
	var yes_button = find_child("YesButton")
	var no_button = find_child("NoButton")
	
	if skill_label:
		skill_label.text = skill_display_name
	if yes_button:
		yes_button.pressed.connect(_on_yes_pressed)
	if no_button:
		no_button.pressed.connect(_on_no_pressed)

func setup(id: String, display_name: String):
	skill_id = id
	skill_display_name = display_name

func _on_yes_pressed():
	SkillManager.unlock_skill(skill_id)
	print("Habilidad robada / Skill stolen: ", skill_id)
	get_tree().paused = false
	queue_free()

func _on_no_pressed():
	print("Habilidad rechazada / Skill rejected: ", skill_id)
	get_tree().paused = false
	queue_free()
