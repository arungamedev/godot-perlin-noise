extends Node3D

@export var point : PackedScene
var level = 0
var z = []

@onready var player = $CharacterBody3D
@onready var cam = $CharacterBody3D/Camera3D
var speed = 10
var mouse_sensitivity = 0.002

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for c in $Points.get_children():
		c.queue_free()
	
	z.clear()
	
	for x in range(-58.0,58.0):
		z.append([])
		for y in range(-58.0,58.0):
			z[int(x)+58].append(0.0)
	
	for o in range(0,level+1):
		var theta = []
		
		for a in range(0,2**o+1):
			theta.append([])
			for b in range(0,2**o+1):
				theta[a].append(randf_range(-PI,PI))
				
		for a in range(0,2**o):
			for b in range(0,2**o):
				for x in range(58.0*(-1.0+a*2.0**(1.0-o)),58.0*(-1.0+(a+1.0)*2.0**(1.0-o))):
					for y in range(58.0*(-1.0+b*2.0**(1.0-o)),58.0*(-1.0+(b+1.0)*2.0**(1.0-o))):
						var sw = 64.80*(((x+58.0)/115.20-a*2.0**(-o))*cos(theta[a][b]) + ((y+58.0)/115.20-b*2.0**(-o))*sin(theta[a][b]))
						var se = 64.80*(((x+58.0)/115.20-(a+1.0)*2.0**(-o))*cos(theta[a+1][b]) + ((y+58.0)/115.20-b*2.0**(-o))*sin(theta[a+1][b]))
						var nw = 64.80*(((x+58.0)/115.20-a*2.0**(-o))*cos(theta[a][b+1]) + ((y+58.0)/115.20-(b+1.0)*2.0**(-o))*sin(theta[a][b+1]))
						var ne = 64.80*(((x+58.0)/115.20-(a+1.0)*2.0**(-o))*cos(theta[a+1][b+1]) + ((y+58.0)/115.20-(b+1.0)*2.0**(-o))*sin(theta[a+1][b+1]))
						
						var smoothstepx = smoothstep(a*2.0**(-o),(a+1.0)*2.0**(-o),(x+58.0)/115.20)
						var smoothstepy = smoothstep(b*2.0**(-o),(b+1.0)*2.0**(-o),(y+58.0)/115.20)
						
						z[int(x)+58][int(y)+58] += sw + (se-sw)*smoothstepx + (nw-sw)*smoothstepy + (ne-nw-se+sw)*smoothstepx*smoothstepy
	
	#Show only final level
	for x in range(-58.0,58.0):
		for y in range(-58.0,58.0):
			var p = point.instantiate()
			$Points.add_child(p)
			p.global_position = Vector3(x,z[int(x)+58][int(y)+58],y)


func _on_level_changed(value: float) -> void:
	level = value
	_ready()


func _physics_process(delta):
	var input = Input.get_vector("left", "right", "forward", "back")
	var movement_dir = player.transform.basis * Vector3(input.x, 0, input.y)
	player.velocity.x = movement_dir.x * speed
	player.velocity.z = movement_dir.z * speed

	player.move_and_slide()
	player.velocity.y = Input.get_axis("down","up") * speed
	
	if Input.is_action_just_pressed("rmb"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif Input.is_action_just_released("rmb"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _input(event):
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		player.rotate_y(-event.relative.x * mouse_sensitivity)
		cam.rotate_x(-event.relative.y * mouse_sensitivity)
		cam.rotation.x = clampf(cam.rotation.x, -deg_to_rad(90), deg_to_rad(90))
