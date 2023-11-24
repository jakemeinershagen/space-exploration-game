extends VehicleBody3D

@onready var player = get_parent().get_node("Player")
@onready var follow_cam = $FollowCam
@onready var ship_cam = follow_cam


func _on_button_interact():
	player.start_ship_mode()
	ship_cam.make_current()
