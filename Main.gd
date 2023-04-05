extends Node2D

var delay = 0

var selection = 0
var spacing = 0
var names = []
var games = []

func _ready():
	var file = File.new()
	if !file.file_exists("user://games.txt"):
		file.open("user://games.txt", File.WRITE)
		file.close()
	else:
		file.open("user://games.txt", File.READ)
		var lines = file.get_as_text(true).split("\n")
		for line in lines:
			var content = line.split("\"")
			if content.size() == 5:
				names.append(content[1])
				games.append(content[3])
		file.close()
		if games.size() > 0:
			update_text()

func update_text():
	$Text.text = ""
	
	var spaces = " " if spacing == 0 else "   "
	
	for i in names.size():
		$Text.text += (("->" + spaces) if i == selection else "") + names[i] + ((spaces + "<-") if i == selection else "") + (("\n\n" if games.size() <= 8 else "\n") if i < names.size()-1 else "")

var time = 0.0

func _process(delta):
	if delay > 0:
		delay -= delta
	
	if games.size() > 0 and delay <= 0:
		time += delta
		if time >= 1.0:
			spacing = 2 if spacing == 0 else 0
			time -= 1.0
			update_text()
		
		if Input.is_action_just_pressed("ui_up"):
			selection = (selection - 1 + games.size()) % games.size()
			update_text()
		
		if Input.is_action_just_pressed("ui_down"):
			selection = (selection + 1) % games.size()
			update_text()
		
		if Input.is_action_just_pressed("ui_accept"):
			OS.window_fullscreen = false
			OS.window_size = Vector2(int(1248/3), int(1024/3))
			$Tween.interpolate_callback(self, 0.1, "execute_game", selection)
			$Tween.start()

func execute_game(game_selection):
	delay = 2.0
	OS.execute(games[game_selection], [], true)
	OS.window_fullscreen = true
