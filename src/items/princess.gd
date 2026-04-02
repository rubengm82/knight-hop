extends Node2D

@onready var animation: AnimatedSprite2D = $Animation

func _ready() -> void:
	update_animation()

func update_animation() -> void:
	animation.play("idle")
