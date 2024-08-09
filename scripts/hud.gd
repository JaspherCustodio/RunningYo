extends CanvasLayer
class_name UI

@onready var fade = $Fade as Fade
#scores label
@onready var score_label = $ScoreLabel
@onready var scored_label = $GameOverMenu/GameOver/ScoredLabel
@onready var high_score_label = $GameOverMenu/GameOver/HighScoreLabel
#audioserver
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var music_slider = $SettingsMenu/MarginContainer/VBoxContainer/GridContainer/MusicSlider
#menus
@onready var pause_menu = $PauseMenu
@onready var settings_menu = $SettingsMenu
@onready var game_over_menu = $GameOverMenu
#buttons
@onready var pause_button = $PauseButton
@onready var resume_pause_button = $PauseMenu/VBoxContainer/ResumeButton
@onready var restart_game_over_button = $GameOverMenu/GameOver/HBoxContainer/Restart
#anim
@onready var animation_player = $AnimationPlayer
@onready var color_rect = $ColorRect


func _ready():
	animation_player.play("RESET")

func scored(score):
	score_label.text = format_number_with_commas(score) + "M"

func format_number_with_commas(number: int) -> String:
	var number_str = str(number)
	var formatted_str = ""
	var count = 0
	
	for i in range(number_str.length() - 1, -1, -1):
		formatted_str = number_str[i] + formatted_str
		count += 1
		if count % 3 == 0 and i != 0:
			formatted_str = "," + formatted_str
	
	return formatted_str

func _on_pause_pressed() -> void:
	get_tree().paused = true
	pause_button.hide()
	animation_player.play("pause_fade")
	await(get_tree().create_timer(0.3).timeout)
	pause_menu.show()
	resume_pause_button.grab_focus()
	animation_player.play("blur")
	await(get_tree().create_timer(0.3).timeout)

func _on_resume_pressed() -> void:
	pause_menu.hide()
	animation_player.play_backwards("pause_fade")
	await(get_tree().create_timer(0.3).timeout)
	pause_button.show()
	animation_player.play_backwards("blur")
	await(get_tree().create_timer(0.3).timeout)
	get_tree().paused = false

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_pause_button_pressed():
	if pause_button.pressed and !get_tree().paused:
		_on_pause_pressed()
	elif pause_button.pressed and get_tree().paused:
		_on_resume_pressed()

func _on_settings_button_pressed():
	settings_menu.show()
	animation_player.play("settings_fade")
	music_slider.grab_focus()

func _on_back_button_pressed():
	animation_player.play_backwards("settings_fade")
	await(get_tree().create_timer(0.2).timeout)
	settings_menu.hide()

func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))

func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(value))

func set_shader_blur_intensity(new_value: float):
	color_rect.material.set_shader_parameter("lod", new_value)

func on_game_over(score, high_score):
	if fade != null: 
		fade.play()
	pause_button.hide()
	animation_player.play("game_over_fade")
	await(get_tree().create_timer(0.3).timeout)
	var tween = get_tree().create_tween()
	tween.tween_method(set_shader_blur_intensity, 0.0, 1.5, 0.9)
	await(get_tree().create_timer(3).timeout)
	game_over_menu.show()
	scored_label.text = "SCORE: " + format_number_with_commas(score) + "M"
	high_score_label.text = "HIGH SCORE: " + format_number_with_commas(high_score) + "M"
	restart_game_over_button.grab_focus()
	get_tree().paused = true
