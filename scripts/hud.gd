extends CanvasLayer

# Referencias a las barras
# References to the bars
@onready var health_bar = $VBoxContainer/HealthBar
@onready var energy_bar = $VBoxContainer/EnergyBar

func _ready():
	# Buscar al jugador y conectar señales
	# Find player and connect signals
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.health_changed.connect(_on_health_changed)
		player.energy_changed.connect(_on_energy_changed)
	else:
		print("HUD: jugador no encontrado / player not found")

func _on_health_changed(current: float, maximum: float):
	# Actualizar barra de vida
	# Update health bar
	health_bar.max_value = maximum
	health_bar.value = current

func _on_energy_changed(current: float, maximum: float):
	# Actualizar barra de energía
	# Update energy bar
	energy_bar.max_value = maximum
	energy_bar.value = current
