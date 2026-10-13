class_name MovementComponent
extends Node
## Movimento com aceleração e atrito suaves para CharacterBody2D.
## A direção deve vir normalizada (Input.get_vector), então a diagonal tem a mesma velocidade.

@export var body: CharacterBody2D

var max_speed: float = 200.0
var acceleration: float = 2000.0
var friction: float = 2400.0


func configure(speed: float, accel: float, fric: float) -> void:
	max_speed = speed
	acceleration = accel
	friction = fric


func move(direction: Vector2, speed_multiplier: float, delta: float) -> void:
	var target := direction.limit_length(1.0) * max_speed * speed_multiplier
	var rate := acceleration if direction != Vector2.ZERO else friction
	# Acima da velocidade máxima (knockback), freia com o atrito.
	if body.velocity.length_squared() > target.length_squared() + 1.0:
		rate = maxf(rate, friction)
	body.velocity = body.velocity.move_toward(target, rate * delta)
	body.move_and_slide()


func stop(delta: float) -> void:
	move(Vector2.ZERO, 0.0, delta)


func move_with_velocity(velocity: Vector2) -> void:
	body.velocity = velocity
	body.move_and_slide()


## Knockback é um impulso na velocidade que o atrito desfaz.
func apply_knockback(impulse: Vector2) -> void:
	body.velocity += impulse
