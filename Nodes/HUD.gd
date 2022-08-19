extends CanvasLayer

onready var timer_label = $"%timer_counter"
onready var lap_label: RichTextLabel = $"%LapLabel"
onready var start_label: RichTextLabel = $"%StartLabel"
onready var middle_panel: Panel = $"%MiddlePanel"
onready var speed_label: Label = $"%SpeedLabel"
onready var km_counter = $"%kilometers_counter"
onready var win_screen = $"%WinScreen"
onready var pause = $PauseScene
var lap_start = 0
var total_time = 0

var running = false

# Called when the node enters the scene tree for the first time.
func _ready():
	lap_label.hide()
	timer_label.hide()
	middle_panel.hide()


func _process(_delta):
	
	if Input.is_action_just_pressed("Pause"):
		get_tree().paused = true
		pause.pause()
	
	if running:
		total_time = OS.get_unix_time() - lap_start
		var minutes = total_time / 60
		var seconds = total_time % 60
		var str_elapsed = "%02d'%02d''" % [minutes, seconds]
		lap_label.bbcode_text = "[right]lap: " + str_elapsed + "[/right]"

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

func game_over():
	middle_panel.show()
	timer_label.hide()
	lap_label.hide()
	running = false
	start_label.bbcode_text = "[center]Game Over[/center]"
	
	

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
