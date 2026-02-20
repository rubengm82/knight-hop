extends CharacterBody2D

@onready var animation = $Animation

func _ready() -> void:
	animation.play('idle')
