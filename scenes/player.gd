extends CharacterBody2D

const SPEED = 250.0
const JUMP_VELOCITY = -400.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var _can_climb : bool = false
var can_climb : bool :
	get : 
		return _can_climb
	set(value):
		_can_climb = value

func set_color(color : Color):
	self.modulate = color

func jump():
	if is_on_floor():
		velocity.y = JUMP_VELOCITY
		$JumpSfx.play()

func _physics_process(delta):

	if not is_on_floor():
		velocity.y += gravity * delta
	elif Input.is_action_just_pressed("jump"):
		self.jump()

	if _can_climb and Input.is_action_pressed("ui_up"):
		velocity.x = 0
		velocity.y = JUMP_VELOCITY / 4
	else:
		var direction = Input.get_axis("ui_left", "ui_right")
		var on_floor = is_on_floor()
		var local_speed = SPEED
		if not on_floor:
			local_speed = local_speed / 2
			$AnimatedSprite2D.play("jump")
		
		if direction:
			velocity.x = direction * local_speed
			$AnimatedSprite2D.play("run")
			if direction == -1:
				$AnimatedSprite2D.flip_h = true
			else:
				$AnimatedSprite2D.flip_h = false
		else:
			$AnimatedSprite2D.play("idle")
			velocity.x = move_toward(velocity.x, 0, local_speed / 2)

	bounds()
	move_and_slide()

func bounds():
	if self.position.x <= 2:
		self.position.x = 3
		if self.velocity.x < 0:
			self.velocity.x = 0
	elif self.position.x >= 1330:
		self.position.x = 1329
		if self.velocity.x > 0:
			self.velocity.x = 0
