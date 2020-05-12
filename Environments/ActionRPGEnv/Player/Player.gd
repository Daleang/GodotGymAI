extends KinematicBody2D

export var ACCELERATION = 500
export var MAX_SPEED = 80
export var ROLL_SPEED = 120
export var FRICTION = 500
var velocity = Vector2.ZERO
var roll_vec = Vector2.DOWN

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox

enum {
	MOVE,
	ROLL,
	ATACK
}
var state = MOVE


func _ready():
	animationTree.active = true

func _process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATACK:
			atack_state(delta)

func move_state(delta):
	var input_vec = Vector2.ZERO
	input_vec.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vec.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vec = input_vec.normalized()
	if input_vec != Vector2.ZERO:
		roll_vec = input_vec
		swordHitbox.knockback_vector = input_vec
		animationTree.set("parameters/Idle/blend_position", input_vec)
		animationTree.set("parameters/Run/blend_position", input_vec)
		animationTree.set("parameters/Atack/blend_position", input_vec)
		animationTree.set("parameters/Roll/blend_position", input_vec)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vec*MAX_SPEED, ACCELERATION*delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION*delta)
	
	move()
	
	if Input.is_action_just_pressed("atack"):
		state = ATACK
		
	if Input.is_action_just_pressed("roll"):
		state = ROLL

func roll_state(delta):
	velocity = roll_vec * ROLL_SPEED
	animationState.travel("Roll")
	move()

func atack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Atack")

func move():
	velocity = move_and_slide(velocity)

func atack_animation_finished():
	state = MOVE
	
func roll_animation_finished():
	velocity = Vector2.ZERO
	state = MOVE
	
