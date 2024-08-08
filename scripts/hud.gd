extends CanvasLayer
class_name UI

@onready var high_score_label = $GameOverMenu/GameOver/HighScoreLabel
@onready var scored_label = $GameOverMenu/GameOver/ScoredLabel
@onready var fade = $Fade as Fade
@onready var score_label = $ScoreLabel
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var settings_menu = $SettingsMenu
@onready var settings_button_game_ready = $GameReadyMenu/SettingsButton
@onready var pause_menu = $PauseMenu
@onready var pause_button = $PauseButton
@onready var game_over_menu = $GameOverMenu
@onready var animation_player = $AnimationPlayer
@onready var music_slider = $SettingsMenu/MarginContainer/VBoxContainer/GridContainer/MusicSlider


func _ready():
	animation_player.play("RESET")

func scored(score):
	score_label.text = format_number_with_commas(score) + "M"

func on_game_over(score, high_score):
	if fade != null: 
		fade.play()
	pause_button.hide()
	get_tree().paused = true
	animation_player.play("blur")
	animation_player.play("game_over_fade")
	scored_label.text = "SCORE: " + format_number_with_commas(score) + "M"
	high_score_label.text = "HIGH SCORE: " + format_number_with_commas(high_score) + "M"
	$GameOverMenu/GameOver/HBoxContainer/Restart.grab_focus()

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
	pause_menu.show()
	animation_player.play("blur")
	animation_player.play("pause_fade")

func _on_resume_pressed() -> void:
	pause_button.show()
	pause_menu.hide()
	get_tree().paused = false
	animation_player.play_backwards("blur")
	animation_player.play_backwards("pause_fade")

func _on_restart_pressed() -> void:
	_on_resume_pressed()
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < 0.5)

func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_BUS_ID, value < 0.5)

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
	settings_menu.hide()
	animation_player.play_backwards("settings_fade")

