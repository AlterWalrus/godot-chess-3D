class_name Piece
extends Node3D

var is_white := true


func system_checks(coords: Vector2):
	if coords < Vector2.ZERO or coords > Vector2.ONE*8:
		return false
	return true


@warning_ignore("unused_parameter")
func custom_checks(coords: Vector2):
	return true

@warning_ignore("unused_parameter")
func move(coords: Vector2):
	return true
	
	#if not system_checks(coords):
		#return
	#
	#if not custom_checks(coords):
		#return
	#
	#print("moving to ", coords)
