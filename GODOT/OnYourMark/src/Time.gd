extends Label

var startTime

func _ready():
	Global.isRunning = false
	
func _process(delta):
	if Global.isRunning:
		start()
		var currentTime =  Time.get_ticks_usec() - startTime
		var seconds = currentTime / 1000000
		var centiseconds = (currentTime % 1000000) / 10000
		text = str(seconds) + ":" + str(centiseconds).pad_zeros(2)
		
	
		
	

func start():
	startTime =  Time.get_ticks_usec()
	Global.isRunning = true

func stop():
	Global.isRunning = false

func reset():
	Global.isRunning = false
	text = "0:00"
