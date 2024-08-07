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

func play_FX(streams: AudioStream, volume = 0.0):
	var fx_play = AudioStreamPlayer.new()
	fx_play.stream = streams
	fx_play.name = "FX_PLAYER"
	fx_play.volume_db = volume
	add_child(fx_play)
	fx_play.play()
	
	await fx_play.finished
	
	fx_play.queue_free()
