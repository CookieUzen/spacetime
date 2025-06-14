extends Node2D

func _ready():
    # Connect multiplayer signals for better feedback
    multiplayer.connected_to_server.connect(_on_connected_to_server)
    multiplayer.connection_failed.connect(_on_connection_failed)
    multiplayer.peer_connected.connect(_on_peer_connected)
    multiplayer.peer_disconnected.connect(_on_peer_disconnected)

func create_server(port: int):
    cleanup()

    var peer = ENetMultiplayerPeer.new()
    var error = peer.create_server(port, 4)
    if error == OK:
        multiplayer.multiplayer_peer = peer
        print("Server created on port: ", port)
    else:
        push_error("Failed to create server: ", error)

func join_server(address: String, port: int):
    cleanup()

    var peer = ENetMultiplayerPeer.new()
    var error = peer.create_client(address, port)
    if error == OK:
        multiplayer.multiplayer_peer = peer
        print("Connecting to server at: ", address, ":", port)
    else:
        push_error("Failed to connect: ", error)

func cleanup() -> void:
    if multiplayer.multiplayer_peer:
        if multiplayer.multiplayer_peer.get_connection_status() != ENetMultiplayerPeer.CONNECTION_DISCONNECTED:
            multiplayer.multiplayer_peer.close()
        multiplayer.multiplayer_peer = null
        print("Multiplayer connection cleaned up")

func display_status() -> void:
    if multiplayer.multiplayer_peer:
        var peer = multiplayer.multiplayer_peer
        var status: String = "Multiplayer Status:\n"
        status += "Connection Status: " + str(peer.get_connection_status()) + "\n"
        status += "Local Peer ID: " + str(multiplayer.get_unique_id()) + "\n"
        status += "Role: " + ("SERVER" if multiplayer.is_server() else "CLIENT") + "\n"
        if multiplayer.is_server():
            status += "Connected Peers: " + str(multiplayer.get_peers()) + "\n"
        print(status)
    else:
        print("No multiplayer peer is set.")

# Signal callbacks
func _on_connected_to_server():
    print("Successfully connected to server!")

func _on_connection_failed():
    push_error("Failed to connect to server")

func _on_peer_connected(id: int):
    print("Peer connected: ", id)

func _on_peer_disconnected(id: int):
    print("Peer disconnected: ", id)

