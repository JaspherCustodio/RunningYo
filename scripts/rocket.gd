extends Area2D

#node
@onready var sprite_2d = $Sprite2D
@onready var collision_shape = $CollisionShape2D
#particles
@onready var explode = $Explosion
@onready var ignite = $Ignite
#audiostream
@onready var exploding: AudioStreamPlayer2D = $Exploding
@onready var warn: AudioStreamPlayer2D = $Warn
#anim
@onready var animation_player = $AnimationPlayer


func _process(_delta):
	position.x -= get_parent().speed / 2
	animation_player.play("moving")

func _on_body_entered(_body):
	collision_shape.set_deferred("disabled", collision_shape)
	sprite_2d.hide()
	warn.playing = false
	ignite.emitting = false
	explode.emitting = true
	exploding.play()
