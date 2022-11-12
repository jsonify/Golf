extends Area2D

export var dir = Vector2.RIGHT
var speed = 300

func _ready():
	$AnimationPlayer.play("Spin")

func _on_Saw_body_entered(body):
	if body.name == "Player":
		body.die()
	else:
		dir *= -1

func _physics_process(delta):
	global_position += dir*speed*delta
