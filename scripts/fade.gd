extends Node
class_name Fade

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var color_rect = $ColorRect
#@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D


func play():
	color_rect.visible = true
	animation_player.play("fade_out")

func _on_animation_player_animation_finished(anim_name):
	queue_free()
