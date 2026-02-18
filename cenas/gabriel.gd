extends Node2D

@export var speed_path_follow: float = 200.0
@export var attack_cooldown_time: float = 3.0
@export var laser_damage: int = 10
@onready var path_follow_2d: PathFollow2D = $Path2D/PathFollow2D
@onready var body: CharacterBody2D = $Path2D/PathFollow2D/gabriel_body
@onready var hp: ProgressBar = $Path2D/PathFollow2D/hp
@onready var player: Node2D = $"../player"
@onready var ray_cast: RayCast2D = $Path2D/PathFollow2D/gabriel_body/RayCast2D
@onready var line_2d: Line2D = $Path2D/PathFollow2D/gabriel_body/Line2D
@onready var attack_timer: Timer = $AttackTimer
@onready var laser_duration: Timer = $LaserTimer

signal tomou_dano

var current_state = "moving"
var target_position: Vector2

func _ready() -> void:
	tomou_dano.connect(_on_tomou_dano)
	attack_timer.wait_time = attack_cooldown_time
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	attack_timer.start()
	laser_duration.wait_time = 0.5
	laser_duration.timeout.connect(_on_laser_duration_timeout)
	ray_cast.enabled = false
	line_2d.visible = false

func _process(delta: float) -> void:
	match current_state:
		"moving":
			path_follow_2d.progress += speed_path_follow * delta
		"aiming":
			pass 
		"firing":
			update_laser_visual()

func _physics_process(_delta: float) -> void:
	if current_state == "firing":
		check_laser_collision()

func _on_attack_timer_timeout() -> void:
	if not is_instance_valid(player): return
	current_state = "aiming"
	fire_laser()

func fire_laser() -> void:
	current_state = "firing"
	var player_local_pos = body.to_local(player.global_position)
	ray_cast.target_position = player_local_pos.normalized() * 2000
	ray_cast.enabled = true
	line_2d.visible = true
	update_laser_visual()
	laser_duration.start()

func update_laser_visual() -> void:
	var cast_point = ray_cast.target_position
	ray_cast.force_raycast_update()
	if ray_cast.is_colliding():
		cast_point = body.to_local(ray_cast.get_collision_point())
	line_2d.points = [Vector2.ZERO, cast_point]

func check_laser_collision() -> void:
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider.has_method("tomou_dano") and collider.name == "player": 
			collider.emit_signal("tomou_dano", laser_damage)

func _on_laser_duration_timeout() -> void:
	current_state = "moving"
	ray_cast.enabled = false
	line_2d.visible = false
	attack_timer.start()

func _on_tomou_dano(value):
	hp.value -= value
	
	var tween := get_tree().create_tween()
	tween.tween_property(body, "modulate", Color.RED, 0.1)
	tween.tween_property(body, "modulate", Color.WHITE, 0.1)
	
	if hp.value <= 0:
		queue_free()
