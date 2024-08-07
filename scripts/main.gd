extends Node

#preload obstacles
var a_obstacle = preload("res://scenes/a_obstacle.tscn")
var a2_obstacle = preload("res://scenes/a_2_obstacle.tscn")
var h_obstacle = preload("res://scenes/h_obstacle.tscn")
var v_obstacle = preload("res://scenes/v_obstacle.tscn")
var rocket = preload("res://scenes/rocket.tscn")
var obstacle_types := [a_obstacle, a2_obstacle, h_obstacle, v_obstacle]
var obstacles: Array
var obstacle_height := [120, 450, 300]
var last_obs

#game variables
const PLAYER_START_POS := Vector2i(242, 424)
const CAM_START_POS := Vector2i(576, 324)

const START_SPEED = 10
const MAX_SPEED: int = 25
const SPEED_MODIFIER: int = 5000
var speed: int

const MAX_DIFFICULTY: int = 2
var difficulty

var screen_size: Vector2i

const SAVE_FILE_PATH = "user://savedata.save"

#score variables
const SCORE_MODIFIER: int = 10
var score: int = 0

var health: = 10:
	set(value):
		health = value
		progress_bar.value = value
		if value <= 0:
			progress_bar.visible = false
			game_over()

@onready var progress_bar = %ProgressBar
#@onready var ground = $Ground
@onready var player = $Player as Player
@onready var camera = $Camera2D
@onready var hud = $HUD as UI
#sound effects
@onready var game_start = preload("res://assets/music&sound/game-start-6104.mp3")


func _ready():
	Music.play_FX(game_start, 0)
	screen_size = get_window().size
	new_game()

func new_game():
	Music.play_music_global()
	difficulty = 0
	#delete all obstacle
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	#reset nodes
	player.position = PLAYER_START_POS
	player.velocity = Vector2i(0, 0)
	camera.position = CAM_START_POS
	
	#reset hud
	hud.get_node("GameReady").show()
	hud.get_node("GameOver").hide()

func _process(_delta):
	if player.is_started:
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		
		adjust_difficulty()
		
		generate_obs()
		
		player.position.x += speed
		camera.position.x += speed
		Music.position.x += speed
		
		#update score
		hud.get_node("ScoreLabel").show()
		score += speed
		show_score()
		
		#update ground position
		#if camera.position.x - ground.position.x > screen_size.x * 1.5:
			#ground.position.x += screen_size.x
		
		#remove obs 
		for obs in obstacles:
			if obs.position.x < (camera.position.x - screen_size.x):
				remove_obs(obs)
		
		hud.get_node("GameReady").hide()

func generate_obs():
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(400, 700):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		obs = obs_type.instantiate()
		var obs_x: int = screen_size.x + score + 900
		var obs_y: int = obstacle_height[randi() % obstacle_height.size()]
		last_obs = obs
		add_obs(obs, obs_x, obs_y)
		
		#random chances to spawn rocket
		if difficulty == MAX_DIFFICULTY:
			if(randi() % 2) == 0:
				for i in range(randi() % max_obs + 1):
					await get_tree().create_timer(1.6).timeout
					var rocket_obs = rocket.instantiate()
					obs_x = screen_size.x + score + 500 + (i * 800)
					obs_y = player.position.y
					add_obs(rocket_obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func hit_obs(body):
	if body.name == "Player":
		progress_bar.visible = true
		take_damage()
		body.apply_damage()
		if health == 0:
			body.kill()

func show_score():
	hud.scored(score / SCORE_MODIFIER)

func check_high_score():
	if score > Global.high_score:
		Global.high_score = score
		hud.on_game_over(score, Global.high_score)
		save_high_score()

func take_damage():
	health -= 1
	Global.camera.shake(0.2, 5)

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

func game_over():
	check_high_score()
	hud.get_node("ScoreLabel").hide()
	hud.get_node("GameOver").show()
	hud.on_game_over(score / SCORE_MODIFIER, Global.high_score / SCORE_MODIFIER)

func save_high_score():
	var save_data = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE_READ)
	save_data.store_32(Global.high_score)

func load_highscore():
	var save_data = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if FileAccess.file_exists(SAVE_FILE_PATH):
		Global.high_score = save_data.get_32()
