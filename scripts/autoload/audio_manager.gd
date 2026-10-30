extends Node
## Pontos de encaixe de áudio. Os sons vêm do AudioLibrary (nome -> AudioStream).
## Se o som estiver vazio, nada acontece e nenhum erro é gerado.

const LIBRARY_PATH := "res://resources/config/audio_library.tres"
const MENU_MUSIC_PATH := "res://assets/audio/music/somMenu.wav"

var library: AudioLibrary
var _sfx_players: Array[AudioStreamPlayer] = []
var _next_player: int = 0
var _music_players: Array[AudioStreamPlayer] = []
var _active_music: int = 0
var _current_music: StringName = &""
var _music_tween: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	library = load(LIBRARY_PATH) as AudioLibrary
	if library == null:
		library = AudioLibrary.new()
	var mage_run_stream := library.sfx.get(&"mage_run") as AudioStreamWAV
	if mage_run_stream:
		mage_run_stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	for i in maxi(library.sfx_voices, 1):
		var player := AudioStreamPlayer.new()
		player.bus = &"SFX"
		add_child(player)
		_sfx_players.append(player)
	for i in 2:
		var music := AudioStreamPlayer.new()
		music.bus = &"Music"
		add_child(music)
		_music_players.append(music)


func play_sfx(sfx_name: StringName) -> void:
	var stream := library.sfx.get(sfx_name) as AudioStream
	if stream == null:
		return
	var player := _sfx_players[_next_player]
	_next_player = (_next_player + 1) % _sfx_players.size()
	player.stream = stream
	player.volume_db = float(library.sfx_volume_db.get(sfx_name, 0.0))
	player.pitch_scale = 1.0 + randf_range(-library.pitch_variation, library.pitch_variation)
	player.play()


func stop_sfx(sfx_name: StringName) -> void:
	var stream := library.sfx.get(sfx_name) as AudioStream
	if stream == null:
		return
	for player: AudioStreamPlayer in _sfx_players:
		if player.stream == stream:
			player.stop()


func play_sfx_on(player: AudioStreamPlayer, sfx_name: StringName) -> void:
	if player == null:
		return
	var stream := library.sfx.get(sfx_name) as AudioStream
	player.stop()
	if stream == null:
		player.stream = null
		return
	player.stream = stream
	player.volume_db = float(library.sfx_volume_db.get(sfx_name, 0.0))
	player.pitch_scale = 1.0 + randf_range(-library.pitch_variation, library.pitch_variation)
	player.play()


func play_music(music_name: StringName) -> void:
	if music_name == _current_music:
		return
	_current_music = music_name
	var stream := library.music.get(music_name) as AudioStream
	if music_name == &"menu" and stream == null:
		stream = load(MENU_MUSIC_PATH) as AudioStreamWAV
	var old := _music_players[_active_music]
	if _music_tween:
		_music_tween.kill()
	if not old.playing and stream == null:
		return
	_music_tween = create_tween().set_parallel(true)
	if old.playing:
		_music_tween.tween_property(old, "volume_db", -40.0, library.music_fade)
		_music_tween.tween_callback(old.stop).set_delay(library.music_fade)
	if stream == null:
		return
	_active_music = 1 - _active_music
	var next := _music_players[_active_music]
	var playable_stream := stream
	if music_name == &"menu" and stream is AudioStreamWAV:
		playable_stream = stream.duplicate() as AudioStreamWAV
		(playable_stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	next.stream = playable_stream
	next.volume_db = -40.0
	next.play()
	_music_tween.tween_property(next, "volume_db", 0.0, library.music_fade)


func stop_music() -> void:
	play_music(&"")
