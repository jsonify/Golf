extends RigidBody2D

export var max_length = 200 # 200
export var force = 800
var touching = false
var start_pos = Vector2.ZERO
var end_pos = Vector2.ZERO
var vector = Vector2.ZERO
var vector_normalized = Vector2.ZERO

var mouse_change = Vector2()

const BOUNCE = preload("res://assets/sounds/bounce2.wav")
const CHARGE = preload("res://assets/sounds/charge-fast.wav")
const THROW = preload("res://assets/sounds/throw-short.wav")
const DIE = preload("res://assets/sounds/impact_0.wav")

onready var walls = $"../Walls"

func _ready():
	$Camera2D.set_as_toplevel(true)
	$Visualizer.set_as_toplevel(true)
	$EnergyIndicator.scale = Vector2(energy,energy)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	G.PlayerNode = self


func _input(event):
	if event is InputEventMouseMotion:
		mouse_change += event.relative
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()


func _physics_process(delta):
	$Camera2D.global_position = $Camera2D.global_position.linear_interpolate(global_position,2*delta)

	if linear_velocity.length() > 30: physics_material_override.bounce = 0.75
	else: physics_material_override.bounce = 0

	$Trail.width = lerp($Trail.width, 10 * clamp(energy,0.1,1), 1*delta)
	$Trail.modulate.a = clamp(energy,0.1,1)
	$BallGlow.modulate.a = energy

	if energy == 0: return
	if Input.is_action_just_pressed("lmb"):
		mouse_change = Vector2()
		$ChargeAudio.play()
	
	if Input.is_action_pressed("lmb"):
		vector = -mouse_change.clamped(max_length)
		vector_normalized = vector/max_length
		touching = true # for drawing
		# lose_energy(0.0025)
		Engine.time_scale = 0.2 # (1 - clamp(energy,0.1,1)) # 0.2
	else:
		touching = false
		# gain_energy()
		Engine.time_scale = 1
	
	if Input.is_action_just_released("lmb"):
		linear_velocity = Vector2.ZERO
		apply_impulse(Vector2.ZERO, vector_normalized*force) # *clamp(energy,0.2,1)
		lose_energy(0.34)
		$ChargeAudio.stop()
		$AudioStreamPlayer.stream = THROW
		$AudioStreamPlayer.play()


var energy = 0.34

func lose_energy(value):
	energy -= value
	energy = clamp(energy, 0, 1)
	$EnergyIndicator.scale = Vector2(energy,energy)

func gain_energy(value):
	energy += value
	energy = clamp(energy, 0, 1)
	$EnergyIndicator.scale = Vector2(energy,energy)

func gain_jump():
	if energy < 0.1:
		energy = 0.34
	$EnergyIndicator.scale = Vector2(energy,energy)

var coll_pos = Vector2()
var coll_normal = Vector2.UP
func _integrate_forces( state ):
	if(state.get_contact_count() >= 1):  #this check is needed or it will throw errors 
		coll_pos = state.get_contact_local_position(0)
		coll_normal = state.get_contact_local_normal(0)

const WALL_TILE = 0
const ANGLE_TILE = 3
const ENERGY_TILE = 1
const SPIKE_TILE = 2

func _on_Player_body_entered(body):
	var coll_over_tile = coll_pos - coll_normal*10
	var cell = walls.world_to_map(coll_over_tile)
	var tile = walls.get_cellv(cell)

	var hit_spikes = coll_normal.dot(tile_orientation(walls,cell.x, cell.y)) > 0.5
	if tile == SPIKE_TILE and hit_spikes:
		die()

	var hit_floor = coll_normal.dot(Vector2.UP) > 0
	if (tile == WALL_TILE or tile == ANGLE_TILE) and hit_floor:
		gain_jump()

	if tile == ENERGY_TILE or body.is_in_group("boxes"):
		gain_energy(0.33)

	# $Visualizer.global_position = coll_over_tile
	# print(linear_velocity.length())
	var perpendicularity = abs(coll_normal.dot(linear_velocity.normalized()))
	$AudioStreamPlayer.volume_db = range_lerp(
		clamp(linear_velocity.length()*perpendicularity,0,100),
		0,100, -50,0
	)
	$AudioStreamPlayer.stream = BOUNCE
	$AudioStreamPlayer.play()

func tile_orientation(tile_map, pos_x, pos_y):
	if tile_map.is_cell_x_flipped(pos_x, pos_y) == false and tile_map.is_cell_y_flipped(pos_x, pos_y) == false:
		return Vector2.UP
	elif tile_map.is_cell_x_flipped(pos_x, pos_y) == true and tile_map.is_cell_y_flipped(pos_x, pos_y) == false:
		return Vector2.RIGHT
	elif tile_map.is_cell_x_flipped(pos_x, pos_y) == false and tile_map.is_cell_y_flipped(pos_x, pos_y) == true:
		return Vector2.LEFT
	elif tile_map.is_cell_x_flipped(pos_x, pos_y) == true and tile_map.is_cell_y_flipped(pos_x, pos_y) == true:
		return Vector2.DOWN

func _process(delta):
	update()

func _draw():
	if not touching: return
	
	# Use global coordinates instead of the local ones
	var inv = get_global_transform().inverse()
	draw_set_transform(inv.get_origin(), inv.get_rotation(), inv.get_scale())

	for i in range(1,10):
		var end = global_position + vector*0.1*i # *energy
#		draw_circle(end,2,Color.white)
		draw_line(global_position, end, Color.blue, 8)
#		draw_line(global_position, end, Color.white, 2)
#		draw_triangle(end, vector.normalized(),Color.white, 4)

func draw_triangle(pos, dir, color, size):
	var a = pos + dir * size
	var b = pos + dir.rotated(2*PI/3) * size
	var c = pos + dir.rotated(4*PI/3) * size
	var points = PoolVector2Array([a, b, c])
	draw_polygon(points, PoolColorArray([color]))

var dead = false
func die():
	if not dead:
		dead = true
		print("DEAD")
		$DieAudio.play()
		hide()
		$Trail.hide()

func _on_DieAudio_finished():
	get_tree().reload_current_scene()
