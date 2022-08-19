extends Node2D

onready var animation = $AnimationPlayer

var scene_to_switch = ""

func change_scene(scene: String):
	scene_to_switch = scene
	animation.play("FadeIn")


func change_scene_impl():
	var _res = get_tree().change_scene(scene_to_switch)
