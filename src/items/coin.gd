extends Area2D

signal coin_collected

@onready var animation = $Animation
@onready var audio_pickup: AudioStreamPlayer = $AudioCoin_pickup
@onready var collision_shape_2d: CollisionShape2D = $Collision

func _ready():
	animation.play('idle')
	# Conectar la señal de colisión con el knight (CharacterBody2D)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# Verificar si el cuerpo es el knight (por su grupo)
	if body.is_in_group("knight"):
		coin_collected.emit()
		animation.visible = false
		# Usar set_deferred para desactivar la colisión
		collision_shape_2d.set_deferred("disabled", true)
		audio_pickup.play()

		# Esperar a que termine el audio antes de eliminar la instancia del coin
		audio_pickup.finished.connect(_on_audio_finished)

func _on_audio_finished() -> void:
	queue_free()
