extends Area2D

# Emitted as soon as the user releases the click
signal vector_created(vector)

export (NodePath) var projectile_path = null
var projectile
const PROJECTILE = preload("res://Launchpad/Ball.tscn")

export var max_length = 64 # 200
var touching = false
var start_pos = Vector2.ZERO
var end_pos = Vector2.ZERO
var vector = Vector2.ZERO
var vector_normalized = Vector2.ZERO 

func _ready():
	connect("input_event", self, "_on_input_event")
	# projectile = get_node(projectile_path)

func _reset():
	start_pos = Vector2.ZERO
	end_pos = Vector2.ZERO
	vector = Vector2.ZERO
	vector_normalized = Vector2.ZERO
	update()

func _on_input_event(_viewport, event, _shape_id):
	# Triggers when an event happens inside the collision shape
	if event.is_action_pressed("lmb"):
		touching = true
		start_pos = event.position
		#start_pos = global_position
		#end_pos = event.position
		
func _input(event):
	if not touching: return
	if event is InputEventMouseMotion:
		end_pos = event.position
		# minus because because we want the vector to point in the opposite direction from dragging
		vector = -(end_pos - start_pos).clamped(max_length)
		vector_normalized = vector/max_length
		update() # rerun the _draw() function
	if event.is_action_released("lmb"):
		touching = false
		emit_signal("vector_created", vector)
		spawn(PROJECTILE)
		_reset()


func _draw():
	var start_global = start_pos - global_position
	var end_global = end_pos - global_position
	draw_line(start_global, end_global, Color.blue, 8)
	draw_line(start_global, start_global + vector, Color.red, 16)

var force = 2000

func spawn(object):
	var instance = object.instance()
	instance.global_position = start_pos
	instance.apply_impulse(Vector2.ZERO, vector_normalized*force)
	owner.add_child(instance)

