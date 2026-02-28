extends Control

@onready var message_text_label: Label = $CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MessageText

var message_text : String :
	set(value):
		message_text_label.text = value
	get:
		return message_text_label.text



func _on_close_message_button_pressed() -> void:
	visible = false
