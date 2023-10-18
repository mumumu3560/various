extends Button


# Called when the node enters the scene tree for the first time.
func _ready():
	self.default_color = Color(0.2, 0.8, 0.2)  # RGB色を指定
	self.hover_color = Color(0.4, 0.9, 0.4)
	self.pressed_color = Color(0.1, 0.6, 0.1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
