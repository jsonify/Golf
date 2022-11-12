extends Control

onready var energy_bar = $MarginContainer/EnergyBar

var max_energy = 100.0
var current_energy = 100.0

func lose_energy(value):
	current_energy -= value
	energy_bar.value = current_energy
