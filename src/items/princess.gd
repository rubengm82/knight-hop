extends Node2D

@onready var animation: AnimatedSprite2D = $Animation

func _ready() -> void:
	update_animation()

func update_animation() -> void:
	animation.play("idle")

# =====================================================
# AREA ENTERED - Cuando a Knight atraviesa el Area2D_goto_finalStage del Stage_pasillo_princess
# =====================================================
func _on_area_2d_goto_final_stage_body_entered(body: Node2D) -> void:
	if body.is_in_group("knight"):
		var nivel = get_parent()
		if nivel.has_method("next_level"):
			nivel.next_level()
