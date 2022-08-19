extends Node

var score_file = "user://score.save"

var current_best = null

func save_to_file():
	var file = File.new()
	file.open(score_file, File.WRITE)
	file.store_64(current_best.total_time)
	file.store_var(current_best.checkpoints, false)
	file.close()


func load_from_file():
	var file = File.new()
	if file.file_exists(score_file):
		current_best = Score.new()
		file.open(score_file, File.READ)
		current_best.total_time = file.get_64()
		current_best.checkpoints = file.get_var(false)
		file.close()


func save_new_score(score: Score):

	if current_best == null or (score.total_time < current_best.total_time):
		current_best = score
		save_to_file()


func get_checkpoint_diff(index: int, new_time: float):
	if current_best == null:
		return 0.0
	else:
		if index < current_best.checkpoints.size():
			return new_time - current_best.checkpoints[index]
		else:
			return 0.0

func is_best_time(time):
	if current_best == null:
		return true
	else:
		return current_best.total_time >= time
