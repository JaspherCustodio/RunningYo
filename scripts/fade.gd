extends Node
class_name Fade

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect = $ColorRect


func play():
	color_rect.visible = true
	animation_player.play("fade_out")

func _on_animation_player_animation_finished(_anim_name):
	queue_free()
