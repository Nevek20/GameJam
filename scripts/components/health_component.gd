class_name HealthComponent
extends Node
## Vida reutilizável. Emite sinais; quem escuta decide o que fazer.

signal health_changed(current: float, maximum: float)
signal damaged(amount: float)
signal died

var max_health: float = 1.0
var current: float = 1.0


func setup(maximum: float) -> void:
	max_health = maxf(maximum, 1.0)
	current = max_health
	health_changed.emit(current, max_health)


func is_dead() -> bool:
	return current <= 0.0


func ratio() -> float:
	return current / max_health


## Retorna o dano efetivamente aplicado.
func take_damage(amount: float) -> float:
	if is_dead() or amount <= 0.0:
		return 0.0
	var applied := minf(amount, current)
	current -= applied
	damaged.emit(applied)
	health_changed.emit(current, max_health)
	if current <= 0.0:
		died.emit()
	return applied


## Volta da morte (revive) com uma quantidade de vida.
func revive(amount: float) -> void:
	current = clampf(amount, 1.0, max_health)
	health_changed.emit(current, max_health)


func heal(amount: float) -> void:
	if is_dead():
		return
	current = minf(current + amount, max_health)
	health_changed.emit(current, max_health)
