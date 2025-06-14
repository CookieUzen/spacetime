extends BoxContainer

@onready var start_server: Button = $StartServer
@onready var join_server: Button = $JoinServer
@onready var address: LineEdit = $Address
@onready var port: LineEdit = $Port
@onready var status: Button = $Status

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_server.pressed.connect(_on_start_server_pressed)
	join_server.pressed.connect(_on_join_server_pressed)
	status.pressed.connect(_on_status_pressed)

func _on_start_server_pressed() -> void:
	var server_port: int = int(port.text.strip_edges())
	Multiplayer.create_server(server_port)

func _on_join_server_pressed() -> void:
	var server_address: String = address.text.strip_edges()
	var server_port: int = int(port.text.strip_edges())

	Multiplayer.join_server(server_address, server_port)

func _on_status_pressed() -> void:
	# Display the current multiplayer status
	Multiplayer.display_status()
