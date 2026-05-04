extends Node2D

# Referencia al bloque/plataforma
# Reference to the platform block
@onready var bloque = $bloque

# Escena siguiente
# Next scene
const NEXT_SCENE = "res://scenes/universe_1.tscn"

# Si ya se activó la secuencia de caída
# If fall sequence already triggered
var sequence_started = false

func _process(_delta):
	# Comprobar si quedan enemigos
	# Check if any enemies remain
	if sequence_started:
		return
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() == 0:
		sequence_started = true
		_start_fall_sequence()

func _start_fall_sequence():
	# Desmayar al jugador
	# Faint the player
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.set_physics_process(false)
		player.set_process(false)
	# Esperar un momento y romper la plataforma
	# Wait a moment and break the platform
	await get_tree().create_timer(1.5).timeout
	bloque.queue_free()
	# Esperar a que el jugador caiga y cargar siguiente escena
	# Wait for player to fall and load next scene
	await get_tree().create_timer(2.0).timeout
	get_tree().call_deferred("change_scene_to_file", NEXT_SCENE)
