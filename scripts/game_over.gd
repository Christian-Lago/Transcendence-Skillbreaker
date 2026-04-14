extends CanvasLayer

# Referencias a los botones
# Button references
@onready var retry_button = $VBoxContainer/RetryButton
@onready var menu_button = $VBoxContainer/MenuButton

func _ready():
	# Conectar botones
	# Connect buttons
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)
	# Pausar el juego al mostrar game over
	# Pause game when showing game over
	get_tree().paused = true

func _on_retry_pressed():
	# Reanudar y recargar la escena actual
	# Unpause and reload current scene
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed():
	# Reanudar e ir al menú principal
	# Unpause and go to main menu
	get_tree().paused = false
	get_tree().call_deferred("change_scene_to_file", "res://scenes/main.tscn")
