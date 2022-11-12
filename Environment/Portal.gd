extends Area2D

var swallow = false

func _ready():
	$SpinAnimation.play("Spin")

func _on_Portal_body_entered(body):
	if body.name == "Player" and not swallow:
		swallow = true
		$SwallowAnimation.play("Swallow")
		$AudioStreamPlayer.play()
		# get_tree().reload_current_scene()

func _physics_process(delta):
	if swallow:
		print(G.PlayerNode.name)
		G.PlayerNode.apply_central_impulse(global_position - G.PlayerNode.global_position)
		G.PlayerNode.linear_damp = 5
		G.PlayerNode.gravity_scale = 0
		G.PlayerNode.find_node("BallMesh").scale *= 0.96
		G.PlayerNode.find_node("BallGlow").scale *= 0.96
		G.PlayerNode.find_node("EnergyIndicator").scale *= 0.96
		G.PlayerNode.find_node("Trail").width *= 0.96
		G.PlayerNode.find_node("Trail").max_points = 0
		G.PlayerNode.find_node("Trail").remove_point(0)
		G.PlayerNode.find_node("Trail").remove_point(0)




func _on_SwallowAnimation_animation_finished(anim_name):
	hide()
	G.PlayerNode.hide()
	get_parent().next_level()
