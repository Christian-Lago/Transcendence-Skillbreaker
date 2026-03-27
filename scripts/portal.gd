extends Area2D

# Escena siguiente a cargar
# Next scene to load
@export var next_scene: String = ""

func _ready():
	# Conectar señal de entrada
	# Connect body entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Si el jugador toca el portal, cargar siguiente escena
	# If player touches portal, load next scene
	if body.is_in_group("player"):
		if next_scene != "":
			get_tree().change_scene_to_file(next_scene)
		else:
			print("Portal sin destino / Portal without destination")
