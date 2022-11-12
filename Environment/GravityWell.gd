extends Area2D

var swallow = false

func _ready():
	$SpinAnimation.play("Spin")

func _on_Portal_body_entered(body):
	return
	if body.name == "Player" and not swallow:
		swallow = true
		$SwallowAnimation.play("Swallow")
		$AudioStreamPlayer.play()
		# get_tree().reload_current_scene()

func _physics_process(delta):
	var dir = global_position - G.PlayerNode.global_position
	var dist = dir.length()
	if dist < 100:
		G.PlayerNode.apply_central_impulse(dir.normalized()*30)
