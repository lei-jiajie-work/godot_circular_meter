extends Control

@export var origin : Vector2 = Vector2(0,0)
@export var rings : int = 1
# the inner_length must be smaller than the outer_length
@export var inner_length : int = 0
@export var outer_length : int = 100
@export var border_width : int = 2
# funny things happen when your angles are negative or above TAU(2 * PI)
# there are also some interesting interactions when angles are coterminal sometimes
@export var start_angles : Array[float] = [0.0]
@export var end_angles : Array[float] = [TAU]
# the higher this number gets, the more segments there are in your circle, which makes it look smoother at the cost of performance
# whole circles will always be less smooth than a sector
@export var segments : int = 54
@export var antialiasing : bool = true
@export var fill_color : Array[Color] = [Color(1.0, 1.0, 1.0, 1.0)]
@export var background_color : Color = Color(0.5, 0.5, 0.5, 0.5)
@export var border_color : Color = Color(0.0, 0.0, 0.0, 1.0)

func ring_polygon(ori : Vector2, il : int, ol : int, sa : float, ea : float, seg : int = 36) -> PackedVector2Array:
	var points : PackedVector2Array
	var total_angle : float = ea - sa
	var inner_points : PackedVector2Array
	var outer_points : PackedVector2Array
	
	for i in range(seg + 1):
		var angle : float = sa + total_angle * (float(i)/float(seg))
		var point : Vector2 = Vector2(ol * cos(angle), ol * sin(angle))
		outer_points.append(ori + point)
		point = Vector2(il * cos(angle), il * sin(angle))
		inner_points.append(ori + point)
	
	inner_points.reverse()
	inner_points.append(outer_points[0])
	points = outer_points + inner_points
	
	return points

func ring_line(ori : Vector2, il : int, sa : float, ea : float, seg : int = 36) -> PackedVector2Array:
	var points : PackedVector2Array
	var total_angle : float = ea - sa
	
	for i in range(seg + 1):
		var angle : float = sa + total_angle * (float(i) / float(seg))
		var point : Vector2 = Vector2(il * cos(angle), il * sin(angle))
		points.append(ori + point)
	
	return points

func _ready() -> void:
	if update_frequency > 0.0:
		timer.wait_time = update_frequency
		timer.start()

func _draw() -> void:
	var total_length : int = outer_length - inner_length
  # draws the background
	draw_polygon(ring_polygon(origin, inner_length, outer_length, 0.0, TAU, segments), PackedColorArray([background_color]))
	# draws every ring
  for ring in range(1, rings + 1):
		var inl : int = inner_length + float(total_length) * (float(ring - 1) / float(rings))
		var outl : int = inner_length + float(total_length) * (float(ring) / float(rings))
		var ring_poly_points : PackedVector2Array = ring_polygon(
			origin, 
			inl, 
			outl, 
			start_angles[(ring - 1) % start_angles.size()], 
			end_angles[(ring - 1) % end_angles.size()], 
			segments
		)
		var ring_points : PackedVector2Array = ring_line(
			origin, 
			inl, 
			0.0,
			TAU,
			segments
		)
		draw_polygon(ring_poly_points, PackedColorArray([fill_color[(ring - 1) % fill_color.size()]]))
		draw_polyline(ring_points, border_color, border_width, antialiasing)
  # draws the final border
	draw_polyline(
		ring_line(
			origin, 
			outer_length, 
			0.0,
			TAU,
			segments
		),
		border_color,
		border_width,
		antialiasing
	)
