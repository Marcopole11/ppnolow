extends Control
var pulpopass: bool = false
var pulpotimer: int = 700
@onready var pulponode: Node3D = $Node3D/Node3D
@onready var pulpo_animations: AnimationPlayer = $Node3D/Node3D/Pulpo/Pulpo_animations
@onready var spot_light_3d: SpotLight3D = $"Node3D/con deposito/SpotLight3D"
@onready var omni_light_3d: OmniLight3D = $"Node3D/con deposito/OmniLight3D"
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $Node3D/Camera3D/AudioStreamPlayer3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	audio_stream_player_3d.volume_db = -45.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	movingpulpo(0.3)

func _on_start_button_pressed() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func movingpulpo(speed):
	if pulpotimer == 0:
		pulpo_animations.play("wings")
		pulponode.position.x -= speed
	else:
		pulpotimer -=1
	
	if pulponode.position.x < -27.0:
		pulponode.position.x = 17
		pulpotimer = randi_range(700,1300)
	
