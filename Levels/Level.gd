extends Node2D


var levels = [
	"res://Levels/Level00.tscn",
	"res://Levels/Level01.tscn",
	"res://Levels/Level02.tscn",
	"res://Levels/Level03.tscn",
	"res://Levels/Level04.tscn"
]
export var current_level = 0


func next_level():
	current_level += 1
	if current_level < levels.size():
		print("Load level", levels[current_level])
		get_tree().change_scene(levels[current_level])
