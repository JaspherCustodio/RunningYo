extends CharacterBody2D
class_name Player
signal game_started

#player
const JUMP_SPEED: int = -1000
var GRAVITY: int = 4200
#start var
var is_started: bool = false
var should_process_input: bool = true
#particles
@onready var explode = $Explosion
@onready var idle_ignite = $IdleIgnite
@onready var ignite = $Ignite
#node
@onready var sprite_2d = $Sprite2D
@onready var collision_shape = $CollisionShape2D
#audiostream
@onready var running_flying_audio: AudioStreamPlayer2D = $Running_Flying
@onready var damage_audio: AudioStreamPlayer2D = $Damage
#anim
@onready var animation_player = $AnimationPlayer


func _ready():
	ignite.emitting = false
	velocity = Vector2.ZERO
	set_shader_blink_intensity(0.0)
	idle_ignite.emitting = true
	animation_player.play("idle")

func _physics_process(delta):
	if Input.is_action_pressed("jump") && should_process_input:
		if !is_started:
			game_started.emit()
			is_started = true
		# Handle jump
		jump()
	elif !is_started:
		return
	elif is_on_floor():
		animation_player.play("run")
		ignite.emitting = false
	else:
		animation_player.play("fall")
		ignite.emitting = false
	
	velocity.y += GRAVITY * delta
	
	move_and_slide()

func jump():
	velocity.y =JUMP_SPEED
	animation_player.play("jump")
	idle_ignite.emitting = false
	ignite.emitting = true

func apply_damage():
	var tween = get_tree().create_tween()
	tween.tween_method(set_shader_blink_intensity, 1.0, 0.0, 0.5)
	damage_audio.play()

func set_shader_blink_intensity(new_value: float):
	sprite_2d.material.set_shader_parameter("blink_intensity", new_value)

func kill():
	should_process_input = false
	GRAVITY = 0
	sprite_2d.hide()
	collision_shape.set_deferred("disabled", collision_shape)
	explode.emitting = true
	running_flying_audio.playing = false
	ignite.emitting = false
	is_started = false
