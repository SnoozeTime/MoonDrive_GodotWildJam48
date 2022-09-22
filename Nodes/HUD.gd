extends CanvasLayer

onready var timer_label = $"%timer_counter"
onready var lap_label: RichTextLabel = $"%LapLabel"
onready var start_label: RichTextLabel = $"%StartLabel"
onready var middle_panel: Panel = $"%MiddlePanel"
onready var speed_label: Label = $"%SpeedLabel"
onready var km_counter = $"%kilometers_counter"
onready var win_screen = $"%WinScreen"
onready var gameover_screen = $"%GameOverScreen"
onready var pause = $PauseScene
var lap_start = 0
var total_time = 0


var display_checkpoint = 0 # 2 Seconds
var current_checkpoint = 0
var running = false

# Called when the node enters the scene tree for the first time.
func _ready():
	lap_label.hide()
	timer_label.hide()
	middle_panel.hide()


func _process(delta):
	display_checkpoint -= delta
	
	if Input.is_action_just_pressed("Pause"):
		get_tree().paused = true
		pause.pause()
	
	if running:
		total_time = OS.get_unix_time() - lap_start
		var str_elapsed = format_seconds(total_time)
		lap_label.bbcode_text = "[right]lap: " + str_elapsed + "[/right]"
		if display_checkpoint>=0:
			var c = "[color=grey]"
			if current_checkpoint > 0:
				c = "[color=red]+"
			elif current_checkpoint < 0:
				c = "[color=green]-"

			lap_label.bbcode_text += "\n[right]" + c + format_seconds(abs(current_checkpoint)) + "[/color][/right]"

func format_seconds(t) -> String:
	var minutes = int(t) / 60
	var seconds = int(t) % 60
	return "%02d'%02d''" % [minutes, seconds]

func new_lap():
	lap_start = OS.get_unix_time()
	lap_label.show()
	running = true

func show_init():
	middle_panel.show()

func start():
	timer_label.show()
	lap_label.show()


func update_timer(sec: float):

	if sec == 0:
		start_label.bbcode_text = "[center]Start!"
		yield(get_tree().create_timer(0.5), "timeout")
		
		middle_panel.hide()
	else:
		start_label.bbcode_text = "[center]" + String(sec) + "[/center]"

func update_checkpoint(sec: float):
	if sec <= 0:
		timer_label.set_timer(0)
	else:
		timer_label.set_timer(sec)

func new_checkpoint(diff: float):
		current_checkpoint = diff
		display_checkpoint = 2

func game_over():
	middle_panel.hide()
	timer_label.hide()
	lap_label.hide()
	running = false
	gameover_screen.show_gameover_screen()

func finished():
	timer_label.hide()
	lap_label.hide()
	running = false
	
	var best = ScoreManager.is_best_time(total_time)
	win_screen.show_win_screen(total_time, best)

func update_speed(speed_percent):
	# 180
	var speed = stepify(180 * speed_percent, 10)
	km_counter.set_kilo(speed)
