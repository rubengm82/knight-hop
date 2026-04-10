extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $Collision
@onready var audio_boots: AudioStreamPlayer = $AudioBoots_doblejump

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("knight"):
		# Enable double jump for knight
		body.ENABLE_DOUBLE_JUMP = true
		# Hide and disable collision
		sprite.visible = false
		collision_shape_2d.set_deferred("disabled", true)
		# Play Sound
		audio_boots.play()
		# Queue free after audio finishes
		audio_boots.finished.connect(queue_free)
