extends Area2D

@onready var animation_player = $AnimationPlayer
@onready var explode = $Explosion
@onready var sprite_2d = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var ignite = $Ignite
@onready var exploding = preload("res://assets/music&sound/mixkit-arcade-game-explosion-2759.mp3")
@onready var warn = $Warn


func _process(_delta):
	position.x -= get_parent().speed / 2
	animation_player.play("moving")

func _on_body_entered(_body):
	Music.play_FX(exploding, -3)
	sprite_2d.hide()
	warn.playing = false
	explode.emitting = true
	ignite.emitting = false
	collision_shape.set_deferred("disabled", collision_shape)
