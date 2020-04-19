extends KinematicBody2D

onready var nav : Navigation2D = get_parent()
onready var anim_player = $Graphics/AnimationPlayer

enum STATES {IDLE, PATROL, SEARCH, ATTACK}
var cur_state = STATES.IDLE
const ATTACK_RANGE = 300

export var move_speed = 200
var patrol_positions = []
var cur_patrol_ind = 0
var search_positions = []
var cur_search_positions = []
var cur_search_ind = 0
func _ready():
	var search_nodes = get_tree().get_nodes_in_group("search_positions")
	for search_node in search_nodes:
		search_positions.append(search_node.global_position)
	if has_node("PatrolNodes"):
		for child in get_node("PatrolNodes").get_children():
			patrol_positions.append(child.global_position)
			set_state_patrol()

func _process(delta):
	match cur_state:
		STATES.IDLE:
			process_state_idle(delta)
		STATES.PATROL:
			process_state_patrol(delta)
		STATES.SEARCH:
			process_state_search(delta)
		STATES.ATTACK:
			process_state_attack(delta)

func set_state_idle():
	anim_player.play("idle")
	cur_state = STATES.IDLE
	move_to_position(null)

func set_state_patrol():
	anim_player.play("walk")
	cur_state = STATES.PATROL
	waiting_at_patrol_point = false
	cur_wait_time = 0.0

func set_state_search():
	anim_player.play("walk")
	cur_state = STATES.SEARCH
	cur_search_positions = [last_known_enemy_position] + search_positions

var attack_target = null
var last_known_enemy_position = Vector2()
func set_state_attack(target):
	anim_player.play("idle")
	move_to_position(null)
	cur_state = STATES.ATTACK
	attack_target = target
	last_known_enemy_position = target.global_position

func process_state_idle(delta):
	var player = can_see_player()
	if player:
		set_state_attack(player)
		return

var waiting_at_patrol_point = false
var cur_wait_time = 0.0
var max_wait_time = 2.0
func process_state_patrol(delta):
	var player = can_see_player()
	if player:
		set_state_attack(player)
		return
	var cur_patrol_pos = patrol_positions[cur_patrol_ind]
	if waiting_at_patrol_point:
		move_to_position(null)
		cur_wait_time += delta
		if cur_wait_time > max_wait_time:
			waiting_at_patrol_point = false
			anim_player.play("walk")
		return
	else:
		move_to_position(cur_patrol_pos)
	if reached_point(cur_patrol_pos):
		anim_player.play("idle")
		waiting_at_patrol_point = true
		cur_wait_time = 0.0
		cur_patrol_ind += 1
		cur_patrol_ind %= patrol_positions.size()

func process_state_search(delta):
	var player = can_see_player()
	if player:
		set_state_attack(player)
		return
	var cur_search_pos = cur_search_positions[cur_search_ind]
	move_to_position(cur_search_pos)
	if reached_point(cur_search_pos):
		cur_search_ind += 1
		cur_search_ind %= cur_search_positions.size()

var attack_rate = 0.1
var cur_attack_time = 0.0
onready var arms_base = $Graphics/Body/Armbase
onready var fire_point = $Graphics/Body/Armbase/ArmUR/ArmLR/Gun/Firepoint
func process_state_attack(delta):
	set_last_known_enemy_position(attack_target.global_position)
	if in_attack_range(attack_target) and !wall_blocking_aim():
		anim_player.play("idle")
		move_to_position(null)
		cur_attack_time += delta
		if cur_attack_time >= attack_rate:
			cur_attack_time = 0.0
			attack()
	else:
		anim_player.play("walk")
		move_to_position(attack_target.global_position)
	
	if attack_target.global_position.x < global_position.x and facing_right:
		flip()
	if attack_target.global_position.x > global_position.x and !facing_right:
		flip()
	var goal_angle = (attack_target.global_position + Vector2(0, -40) - arms_base.global_position).angle()
	if !facing_right:
		goal_angle *= -1
	arms_base.global_rotation = goal_angle
	
	if can_see_player() == null:
		set_state_search()
	var nearest_player = get_nearest_visible_player()
	if nearest_player and nearest_player != attack_target:
		attack_target = nearest_player
	if is_obj_dead(attack_target):
		set_state_search()

var fire_obj = preload("res://Flame.tscn")
func attack():
	var fire_inst = fire_obj.instance()
	get_tree().get_root().add_child(fire_inst)
	fire_inst.global_position = fire_point.global_position
	if facing_right:
		fire_inst.global_rotation = fire_point.global_rotation
	else:
		fire_inst.global_rotation = -fire_point.global_rotation
	fire_inst.init()

func set_last_known_enemy_position(pos: Vector2):
	last_known_enemy_position = pos

func can_see_player():
	var nearest_player = get_nearest_visible_player()
	if nearest_player != null:
		return nearest_player
	var space_state = get_world_2d().direct_space_state
	var num_of_dir_raycasts = 16
	var angle_increment = deg2rad(100.0 / 16)
	var offset = deg2rad(-50)
	if !facing_right:
		offset += deg2rad(180)
	#update()
	for i in range(num_of_dir_raycasts):
		var result = space_state.intersect_ray(fire_point.global_position, 2000 * Vector2.RIGHT.rotated(offset + i * angle_increment), [self], 1+4)
		if result and "RopeSegment" in result.collider.name and !is_obj_dead(result.collider):
			return result.collider
	return null

#func _draw():
#	var num_of_dir_raycasts = 16
#	var angle_increment = deg2rad(100.0 / 16)
#	var offset = deg2rad(-50)
#	if !facing_right:
#		offset += deg2rad(180)
#	for i in range(num_of_dir_raycasts):
#		var l_pos = to_local(global_position + 2000 * Vector2.RIGHT.rotated(offset + i * angle_increment))
#		draw_line(Vector2.ZERO, l_pos, Color.red, 2)

func get_nearest_visible_player():
	var player_nodes = get_tree().get_nodes_in_group("player")
	var space_state = get_world_2d().direct_space_state
	var visible_players = []
	for player_node in player_nodes:
		if player_node.global_position.x > global_position.x and !facing_right:
			continue
		if player_node.global_position.x < global_position.x and facing_right:
			continue
		var result = space_state.intersect_ray(fire_point.global_position, player_node.global_position, [self], 1)
		if !result and !is_obj_dead(player_node):
			visible_players.append(player_node)
	
	var last_dist = -1
	var nearest = null
	for player_node in visible_players:
		var dist = global_position.distance_squared_to(player_node.global_position)
		if last_dist < 0 or dist < last_dist:
			last_dist = dist
			nearest = player_node
	if nearest != null:
		return nearest
	return null

var goal_pos = null
func _physics_process(delta):
	if goal_pos == null:
		return
	var dir = Vector2()
	if cur_state == STATES.PATROL: #ignore pathfinding in patrol state
		dir = global_position.direction_to(goal_pos)
	else:
		var path = nav.get_simple_path(global_position, goal_pos)
		if path.size() > 1:
			dir = global_position.direction_to(path[1])
	move_and_slide(dir * move_speed, Vector2())
	if dir.x > 0 and !facing_right:
		flip()
	if dir.x < 0 and facing_right:
		flip()

func move_to_position(pos):
	goal_pos = pos

func get_closest_search_position():
	var last_dist = -1
	var nearest = Vector2()
	for search_position in search_positions:
		var dist = global_position.distance_squared_to(search_position)
		if last_dist < 0 or dist < last_dist:
			last_dist = dist
			nearest = search_position
	return nearest

func reached_point(pos: Vector2):
	return global_position.distance_squared_to(pos) < 100*100

var facing_right = true
func flip():
	$Graphics.scale.x *= -1
	facing_right = !facing_right

func wall_blocking_aim():
	var dis = 1000
	if attack_target != null:
		dis = fire_point.global_position.distance_to(attack_target.global_position)
	for child in fire_point.get_children():
		child.cast_to.x = dis
		if child.is_colliding():
			return true
	return false

func is_obj_dead(obj):
	return obj != null and (("burned" in obj and obj.burned) or (
		"is_dead" in obj and obj.is_dead))

func in_attack_range(target):
	return global_position.distance_squared_to(target.global_position) < ATTACK_RANGE * ATTACK_RANGE
