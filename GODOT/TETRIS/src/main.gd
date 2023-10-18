extends Node2D


#ミノを設置させてからミノを消去してその場所にミノを設置するにはどうすればいいのか？
#ミノの接地判定
#ミノの位置情報、回転、ミノの種類を保存する。→Global
#mainの方でField_keepの方でミノを出現させて保存する。
#Field_spawnの方は消去する
#設置後に消去判定を入れる。
#消去された場合、消去されるところは0にする。またミノをずらす必要があるがそれは下から行えばいい
#で終わり？

#holdはどうする？
var hold_mino = "null"
#これはholdを使ったときにholdにあるミノを保存してspawn_minoで使う
var next_mino = "null"
#minog.gdのnow_minoから現在のミノを取得→Field_spawnでqueue_free()→spawn_now=trueにする？redoとの整合性？

#redoはどうする？
#holdを含めると面倒？holdを含めないと、minos_1、minos_2、minos_3を用意して、最初以外はminos_2を参照してミノをスポーンさせる。
#minos_2がなくなったらminos_3をminos_2に渡してminos_3を再抽選。minos1_、minos_2を考えてredoできるようにする。(最大13手？)


var screen_size # Size of the game window.


var original_minos = [ "t_mino","s_mino","i_mino","z_mino", "l_mino", "j_mino", "o_mino", ]
#var original_minos = ["s_mino","i_mino","z_mino", "l_mino", "j_mino","t_mino", "o_mino", ]


var minos = original_minos.duplicate(true)
#minos_1が現在使っているやつで、minos_2が後で使うやつにしたい？
var minos_1 = []
var minos_2 = []
var minos_3 = []

var minos_1_keep = []
var minos_2_keep = []
var minos_3_keep = []
#var selected_mino = minos[randi() % minos.size()]


#ここでField_spawnのx座標が600なのでそこにスポーンする
@onready var _field_mgr = $Field_spawn
@onready var _field_keep = $Field_keep
@onready var _field_area = $mino_area_0
@onready var _field_hold = $mino_area_hold



var spawn_x = 480
var spawn_y = 30

var i_jud = false

var spawn_judge = 1

var hold_push = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var mino_scene = load("res://" + "l_block" + ".tscn")
	var mino2 = mino_scene.instantiate()
	_field_mgr.add_child(mino2)
	
	mino2.position.x += 120#4→9
	mino2.position.y += 240#8→9
	
	screen_size = get_viewport_rect().size
	
	
	
	#ミノの抽選
	mino_list_ready(minos_1)
	mino_list_ready(minos_2)
	mino_list_ready(minos_3)
	#ミノの情報のキープ(redo機能)
	minos_1_keep = minos_1.duplicate(true)
	minos_2_keep = minos_2.duplicate(true)
	minos_3_keep = minos_3.duplicate(true)
	
	spawn_mino()
	
	#next_hold_mino_display()
	
	
	
	
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if(Input.is_action_just_pressed("back_to_title")):
		Global.tetris_grid_keep = Global.tetris_grid.duplicate(true)
		get_tree().change_scene_to_file("res://title.tscn")
	
	if(Input.is_action_just_pressed("reset")):
		Global.tetris_grid_keep = Global.tetris_grid.duplicate(true)
		get_tree().change_scene_to_file("res://main.tscn")
	
	
	if(Global.bbb):
		mino_release()

		#next_hold_mino_display()

		
	
	if(Input.is_action_just_pressed("list_display")):
		print(minos_1)
		print(minos_2)
		print(minos_3) 
		print("??????????????????????????")
		print(minos_1_keep)
		print(minos_2_keep)
		print(minos_3_keep)
		
	
		
		
	if(!Global.spawn_now):
		spawn_mino()
		
	if(Input.is_action_just_pressed("hold") && !Global.hold_now):
		
		mino_release()
		
		hold_act()
		
		#next_hold_mino_display()
		
	if(Global.aaa):
		game_over()
		
		grid_add()
		check_line()
		#L→2、J→3、S→4、Z→5、T→6、O→7、I→8
		for i in range(12):
			print(Global.tetris_grid_keep[i])
			
	next_hold_mino_display()
		



var first_7_minos = true


func mino_list_ready(minos_n):
	while(minos != []):
		var selected_mino = minos.pop_at(randi() % minos.size())
		minos_n.append(selected_mino)
		
	minos = original_minos.duplicate(true)
		
	
#ここで接地判定を行いたい。mino.gdのon_ground()関数からの続きでField_keepにおいて同じ位置にミノを追加したい。
#これはgridをすべて更新することにする。
func grid_add():
	
	for i in range(12):
		for j in range(23):
	
			if(Global.tetris_grid_keep[i][j] == 2):
				var mino_scene = load("res://" + "l_block" + ".tscn")
				var mino2 = mino_scene.instantiate()
				_field_keep.add_child(mino2)
				mino2.position.x += (i-5)*30
				mino2.position.y += (j-1)*30
				
			if(Global.tetris_grid_keep[i][j] == 3):
				var mino_scene = load("res://" + "j_block" + ".tscn")
				var mino2 = mino_scene.instantiate()
				_field_keep.add_child(mino2)
				mino2.position.x += (i-5)*30
				mino2.position.y += (j-1)*30
			
			if(Global.tetris_grid_keep[i][j] == 4):
				var mino_scene = load("res://" + "s_block" + ".tscn")
				var mino2 = mino_scene.instantiate()
				_field_keep.add_child(mino2)
				mino2.position.x += (i-5)*30
				mino2.position.y += (j-1)*30
			
			if(Global.tetris_grid_keep[i][j] == 5):
				var mino_scene = load("res://" + "z_block" + ".tscn")
				var mino2 = mino_scene.instantiate()
				_field_keep.add_child(mino2)
				mino2.position.x += (i-5)*30
				mino2.position.y += (j-1)*30
			
			if(Global.tetris_grid_keep[i][j] == 6):
				var mino_scene = load("res://" + "t_block" + ".tscn")
				var mino2 = mino_scene.instantiate()
				_field_keep.add_child(mino2)
				mino2.position.x += (i-5)*30
				mino2.position.y += (j-1)*30
			
			if(Global.tetris_grid_keep[i][j] == 7):
				var mino_scene = load("res://" + "o_block" + ".tscn")
				var mino2 = mino_scene.instantiate()
				_field_keep.add_child(mino2)
				mino2.position.x += (i-5)*30
				mino2.position.y += (j-1)*30
			
			if(Global.tetris_grid_keep[i][j] == 8):
				var mino_scene = load("res://" + "i_block" + ".tscn")
				var mino2 = mino_scene.instantiate()
				_field_keep.add_child(mino2)
				mino2.position.x += (i-5)*30
				mino2.position.y += (j-1)*30
					
			
	for child in _field_mgr.get_children():
		child.queue_free()
		
		#この先の処理があまり良くない気がしてきた
		Global.aaa = false
		Global.spawn_now = false
				


var line_jud = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
#ここでライン消去を行う。
#ちゃんと稼働するがgrid_addはどうするか
func check_line():
	var line_jud_keep = line_jud.duplicate(true)
		
	
	
	#まずここでどの高さでラインが埋まっているかを確かめる。	
	#1~10列目、0~21行目
	var check = false
	
	for i in range(22):
		for j in range(10):
			
			#ここではある行がミノで埋まっていない場合に次の行に移動するようにする
			if(Global.tetris_grid_keep[j+1][21-i] == 0):
				check = true
				break
				
		if(check):
			check = false
			continue
			
		line_jud_keep[21-i] = 0
	
	#                  [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
	var count_0_list = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
	var count_0 = 0
	
	
	for i in range(22):
		if(line_jud_keep[21-i] == 0):
			count_0 += 1
			
		count_0_list[21-i] = count_0
		

	#ここから上で求めたものからどれだけラインをずらすかを考える。	
	#下からより上からやったほうがよい？
			
	if(count_0 > 0):
		for i in range(22):
			for j in range(10):
				
				if(line_jud_keep[21-i] == 0):
					break
					
				#なんか変だなぁと思っていたがこれがなかったから。これがないと下の二つ目の=0がおかしくなる
				if(count_0_list[21-i] == 0):
					break
					
				Global.tetris_grid_keep[j+1][21-i + count_0_list[21-i] ] = Global.tetris_grid_keep[j+1][21-i]
				Global.tetris_grid_keep[j+1][21-i] = 0				
			
			
	if(count_0 > 0):

		for child in _field_keep.get_children():
			child.queue_free()
			
		grid_add()
		
		
#ミノが一定の高さ以上になったときにゲームオーバー				
func game_over():
	
	for i in range(12):
		print(Global.tetris_grid_keep[i])
	
	
	for i in range(2):
		for j in range(10):
			
			if(Global.tetris_grid_keep[j+1][i] != 0):
				
				print(minos_1)
				print(minos_2)
				print(minos_3) 
				print("LALGOUAHGOUWGUHAEUG")
				print(minos_1_keep)
				print(minos_2_keep)
				print(minos_3_keep)
				
				Global.tetris_grid_keep = Global.tetris_grid.duplicate(true)
				for child in _field_keep.get_children():
					child.queue_free()
			
				

"""


hold管理をここで行いたいがどうすればいい？
spawn_minoと何を分担すればよいか？
hold(Cキー)を押した時の挙動。

・holdが無い場合→現在表示されているミノをholdに付け加えて、次のミノをスポーンさせる。

・holdがある場合→holdをスポーンさせ、現在表示しているミノをholdにする。

holdにあるミノをhold_minoとする。

"""
func hold_act():
	
	#insertでミノを入れようと思ったが、
	#もともと　minos_2=[ "t_mino","s_mino","i_mino","z_mino", "l_mino", "j_mino", "o_mino", ]の時は？
	#spawn_minoの方で調整する？next_minoとかで
	
	#size() = 0の時は？どういう時？
	
	#next_minoは次にスポーンさせるやつにする。
	#holdにミノがある場合はnext_minoにhold_minoを入れる。
	
	
	print("minos_2.size()")
	print(minos_2.size())
	
	print("minos_2")
	print(minos_2)
	
	print("minos_2_keep")
	print(minos_2_keep)
	
	#ここはあってるはず
	if(!(hold_mino == "null")):
		next_mino = hold_mino
		
	hold_mino = Global.appear_mino
	
	"""
	if(minos_2.size() == 7):
		hold_mino = minos_1_keep[0]
	else:
		#minos_2.size()→6の時、
		hold_mino = minos_2_keep[7- minos_2.size()]
	"""
			
			
	for child in _field_mgr.get_children():
		child.queue_free()
			
	Global.hold_now = true
	Global.spawn_now = false
	hold_push = true
	
	#next_hold_mino_display()


#ミノのスポーン
func spawn_mino():
	#ここでスポーン。mino1がなくなったらmino2をコピーしてmino2は新たにランダムに作成
	"""
	if(minos_2 == []):
		
		minos_1 = minos_2_keep.duplicate(true)
		minos_1_keep = minos_1_keep.duplicate(true)
		
		minos_2 = minos_3.duplicate(true)
		minos_2_keep = minos_2.duplicate(true)
		
		minos_3 = []
		mino_list_ready(minos_3)
		minos_3_keep = minos_3.duplicate(true)
		
	"""
		
		
	#var selected_mino = minos_1.pop_at(randi() % minos_1.size())
	var selected_mino
	
	
	print("hold_mino")
	print(hold_mino)
	
	
	if(hold_push):
		
		if(next_mino == "null"):
			selected_mino = minos_2.pop_at(0)
		else:
			selected_mino = next_mino
			
	else:
		selected_mino = minos_2.pop_at(0)
		
	"""
	if(hold_mino == "null"):
		selected_mino = minos_2.pop_at(0)
		
	else:
		if(hold_push):
			selected_mino = next_mino
		else:
			selected_mino = minos_2.pop_at(0)
	"""
	
	print("next_mino")
	print(next_mino)
			
	
	hold_push = false			
	#nextがある場合は
	
	"""
	if(next_mino == "null"):
		selected_mino = minos_2.pop_at(0)
	else:
		if(hold_push):
			selected_mino = next_mino
		else:
			selected_mino = minos_2.pop_at(0)


		selected_mino = next_mino
		next_mino = "null"
	"""
		
	
	#if selected_mino == "i_mino":
	#	i_jud = true

		
	var mino_scene = load("res://" + selected_mino + ".tscn")
	var mino = mino_scene.instantiate()

	_field_mgr.add_child(mino)
	
	#var mino_keep_scene = load("res://" + selected_mino + "_keep.tscn")
	#var mino_keep = mino_keep_scene.instantiate()
	#_field_mgr.add_child(mino_keep)
	#mino_keep.position.y += 60
	
	
	if selected_mino == "i_mino":
		mino.position.y += 30
		i_jud = false
	
	Global.spawn_now = true
	
	if(minos_2 == []):
		
		minos_1 = minos_2_keep.duplicate(true)
		minos_1_keep = minos_1_keep.duplicate(true)
		
		minos_2 = minos_3.duplicate(true)
		minos_2_keep = minos_2.duplicate(true)
		
		minos_3 = []
		mino_list_ready(minos_3)
		minos_3_keep = minos_3.duplicate(true)
		
		
		

#7種1巡を二つここで準備しておく。




#nextのミノの管理
func next_hold_mino_display():
	
	var mino_size = minos_2.size()
	
	#ミノサイズが3→range(3)→012
	for i in range(mino_size):
		if(i == 5):
			break
		
		var mino_scene = load("res://" + minos_2[i] + "_keep.tscn")
		var mino = mino_scene.instantiate()
		_field_area.add_child(mino)
		mino.position.y += i*120
		mino.scale.x = 0.7
		mino.scale.y = 0.7
		
		mino.position.x += 45
		mino.position.y += 30
		
	#ミノサイズが3→range(6-3)→012
	#ミノサイズが3→range(5-3)→01
	for i in range(5-mino_size):
		
		var mino_scene = load("res://" + minos_3[i] + "_keep.tscn")
		var mino = mino_scene.instantiate()
		_field_area.add_child(mino)
		mino.position.y += i*120 + 120*mino_size
		mino.scale.x = 0.7
		mino.scale.y = 0.7
		
		mino.position.x += 45
		mino.position.y += 30
		
	if(!(hold_mino == "null")):
		var mino_scene = load("res://" + hold_mino + "_keep.tscn")
		var mino = mino_scene.instantiate()
		_field_hold.add_child(mino)
		mino.scale.x = 0.7
		mino.scale.y = 0.7
		
		mino.position.x += 45
		mino.position.y += 30
		
		

func mino_release():
	for child in _field_hold.get_children():
		child.queue_free()
		
	for child in _field_area.get_children():
		child.queue_free()
	
		
		
		
	
	
	
	
