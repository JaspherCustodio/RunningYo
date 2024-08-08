extends CharacterBody2D
class_name Player
signal game_started

const JUMP_SPEED: int = -1000
var GRAVITY: int = 4200
var is_started: bool = false
var should_process_input: bool = true

@onready var explode = $Explosion
@onready var ignite = $Ignite
@onready var idle_ignite = $IdleIgnite
@onready var animation_player = $AnimationPlayer
@onready var sprite_2d = $Sprite2D
@onready var collision_shape = $CollisionShape2D
@onready var running_flying: AudioStreamPlayer2D = $Running_Flying
@onready var damage: AudioStreamPlayer2D = $Damage


func _ready():
	velocity = Vector2.ZERO
	set_shader_blink_intensity(0.0)
	animation_player.play("idle")
	ignite.emitting = false
	idle_ignite.emitting = true

func _physics_process(delta):
	# Handle jump.
	if Input.is_action_pressed("jump") && should_process_input:
		if !is_started:
			game_started.emit()
			is_started = true
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
	ignite.emitting = true
	idle_ignite.emitting = false

func apply_damage():
	damage.play()
	var tween = get_tree().create_tween()
	tween.tween_method(set_shader_blink_intensity, 1.0, 0.0, 0.5)

func set_shader_blink_intensity(new_value: float):
	sprite_2d.material.set_shader_parameter("blink_intensity", new_value)

func kill():
	running_flying.playing = false
	sprite_2d.hide()
	explode.emitting = true
	ignite.emitting = false
	collision_shape.set_deferred("disabled", collision_shape)
	GRAVITY = 0
	should_process_input = false
	is_started = false
