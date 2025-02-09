extends Control
@onready var label: Label = $Label
@onready var label_2: Label = $Label2
@onready var mantis_walk: AnimationPlayer = $mantis_walk
var randomizer:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	randomizer = randi_range(0,50)
	label.show()
	label_2.hide()
	if randomizer == 1:
		label_2.show()
		label.hide()
		mantis_walk.play("idle")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_main_menu_pressed() -> void:
	get_tree().quit()
