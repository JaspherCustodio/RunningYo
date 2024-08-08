extends AudioStreamPlayer2D

const global_music = preload("res://assets/music&sound/NJJ_Theme.mp3")

func play_music(music: AudioStream, volume = 0.0):
	if stream == music:
		return
	stream = music
	volume_db = volume
	play()

func play_music_global():
	play_music(global_music)
