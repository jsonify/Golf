extends Area2D


func _ready():
	pass


func _on_Powerup_body_entered(body):
	if body.name == "Player":
		body.gain_energy(1)
		queue_free()
