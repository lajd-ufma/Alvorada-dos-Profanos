extends Area2D

var direction = 1
const speed = 10
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(3).timeout
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x+= speed*direction

func _on_body_entered(body: Node2D) -> void:
	body.emit_signal("tomou_dano")
	queue_free()
