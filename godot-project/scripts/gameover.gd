extends Control
@onready var label: Label = $MarginContainer/Label
@onready var label_2: Label = $MarginContainer/Label2
@onready var mantis_walk: AnimationPlayer = $mantis_walk
var randomizer:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_main_menu_pressed() -> void:
	get_tree().quit()
