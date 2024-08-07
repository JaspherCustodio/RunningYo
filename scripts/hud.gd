extends CanvasLayer
class_name UI

@onready var game_over = $GameOver
@onready var high_score_label = $GameOver/HighScoreLabel
@onready var scored_label = $GameOver/ScoredLabel
@onready var fade = $Fade as Fade
@onready var color_rect = $ColorRect
@onready var score_label = $ScoreLabel
@onready var SFX_BUS_ID = AudioServer.get_bus_index("SFX")
@onready var MUSIC_BUS_ID = AudioServer.get_bus_index("Music")
@onready var settings = $Settings

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		settings.visible = !settings.visible

func scored(score):
	score_label.text = format_number_with_commas(score) + "M"

func on_game_over(score, high_score):
	if fade != null: 
		fade.play()
	color_rect.visible = true
	scored_label.text = "SCORE: " + format_number_with_commas(score) + "M"
	high_score_label.text = "HIGH SCORE: " + format_number_with_commas(high_score) + "M"
	game_over.visible = true
	$GameOver/Panel/HBoxContainer/Restart.grab_focus()

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

func _on_restart_pressed() -> void:
	get_tree().reload_current_scene()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(MUSIC_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(MUSIC_BUS_ID, value < 0.5)

func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(SFX_BUS_ID, linear_to_db(value))
	AudioServer.set_bus_mute(SFX_BUS_ID, value < 0.5)

func _on_settings_button_pressed():
	settings.visible = !settings.visible
	if settings.visible == true:
		return
