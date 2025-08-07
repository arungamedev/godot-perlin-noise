extends Node2D

@export var point : PackedScene
var level = 0
var max_level = 10
var y = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/SpinBox.max_value = max_level
	
	for c in $Points.get_children():
		c.queue_free()
	
	y.clear()
	
	for x in range(-576.0,576.0):
		y.append(0.0)
	
	for o in range(0,max_level+1):
		var eps = [randf_range(-1,1)]
		for a in range(0,2**o):
			eps.append(randf_range(-1,1))
			for x in range(576.0*(-1.0+a*2.0**(1.0-o)),576.0*(-1.0+(a+1.0)*2.0**(1.0-o))):
				var left = 648.0*((x+576.0)/1152.0-a*2.0**(-o))*eps[a]
				var right = 648.0*((x+576.0)/1152.0-(a+1)*2.0**(-o))*eps[a+1]
				
				var smoothstep = smoothstep(a*2.0**(-o),(a+1.0)*2.0**(-o),(x+576.0)/1152.0)
				
				y[int(x)+576] += left + (right - left) * smoothstep
				
				#show each level
				var p = point.instantiate()
				p.global_position = Vector2(x,y[x+576])
				p.add_to_group(str(o))
				if o != level:
					p.hide()
				$Points.add_child(p)


func _on_level_changed(value: float) -> void:
	level = value
	for l in range(0,level):
		for p in get_tree().get_nodes_in_group(str(l)):
			p.hide()
	
	for l in range(level,level+1):
		for p in get_tree().get_nodes_in_group(str(l)):
			p.show()
	
	for l in range(level+1,max_level+1):
		for p in get_tree().get_nodes_in_group(str(l)):
			p.hide()
	
