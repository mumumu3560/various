extends Node2D

#Iミノが面倒分数でやる？他のところより基準からの距離が近い？
var tetriminos_integrate = [
	
#0
[  [ [1,-1], [0,0], [1,0], [-1,0] ], #Lミノok
[ [-1,-1], [1,0], [-1,0], [0,0] ], #Jミノ ok
[ [0,0], [-1,0], [0,-1], [1,-1] ], #Sミノ ok
[ [0,0], [0,-1], [-1,-1], [1,0] ], #Zミノ ok
[ [0,0], [-1,0], [1,0], [0,-1] ], #Tミノ ok
[ [-0.5,-0.5], [-0.5,0.5], [0.5,-0.5], [0.5,0.5] ], #Oミノ
[ [0.5,-0.5], [1.5,-0.5], [-0.5,-0.5], [-1.5,-0.5] ]   ],

#90
[  [ [0,1], [0,-1], [0,0], [1,1] ], #Lミノok
[ [0,1], [0,-1], [1,-1], [0,0] ], #Jミノ ok
[ [0,0], [0,-1], [1,0], [1,1] ], #Sミノ ok
[ [0,0], [1,0], [0,1], [1,-1] ], #Zミノ ok
[ [0,0], [1,0], [0,1], [0,-1] ], #Tミノ ok
[ [-0.5,-0.5], [-0.5,0.5], [0.5,-0.5], [0.5,0.5] ], #Oミノ
[ [0.5,1.5], [0.5,0.5], [0.5,-0.5], [0.5,-1.5] ]   ], #Iミノ ok?

#180
[  [ [1,0], [0,0], [-1,0], [-1,1] ], #Lミノ ok
[ [1,1], [1,0], [-1,0], [0,0] ], #Jミノ ok
[ [0,0], [-1,1], [1,0], [0,1] ], #Sミノ ok
[ [0,0], [-1,0], [1,1], [0,1] ], #Zミノ ok
[ [0,0], [-1,0], [1,0], [0,1] ], #Tミノ ok
[ [-0.5,-0.5], [-0.5,0.5], [0.5,-0.5], [0.5,0.5] ], #Oミノ
[ [0.5,0.5], [1.5,0.5], [-0.5,0.5], [-1.5,0.5] ]   ], #Iミノ

#270
[  [ [0,-1], [0,0], [0,1], [-1,-1] ], #Lミノ ok
[ [0,1], [0,-1], [-1,1], [0,0] ], #Jミノ ok
[ [0,1], [-1,-1], [-1,0], [0,0] ], #Sミノ ok
[ [0,0], [-1,0], [-1,1], [0,-1] ], #Zミノ ok
[ [0,0], [-1,0], [0,1], [0,-1] ], #Tミノ ok
[ [-0.5,-0.5], [-0.5,0.5], [0.5,-0.5], [0.5,0.5] ], #Oミノ
[ [-0.5,-1.5], [-0.5,-0.5], [-0.5,0.5], [-0.5,1.5] ]   ]
	
]




#横移動やソフトドロップの速さ調節
var count_deltaL = 0
var count_deltaR = 0
var count_delta_soft = 0

var count_free_fall = 0
var count_rotation = 0

#ミノが地面や他のミノにぶつかったときにどれくらいで設置されるかの時間テキトーに調整
var till_ground_time = 0
#ミノの下に何かブロックがあるかを判定
var on_block = false
#これは動かしたらタイマーがリセットされるようにするがリセットできる回数も決めておく。
var till_ground_count = 0
#最初に設置したとき
var first_ground = false

#ミノの種類
#ここでめちゃくちゃいきづまった
@onready var now_mino = $ColorRect2.get_parent().name
@onready var _mino_ghost = $mino_ghost
#元々は@onreadyがついてなかった。。


var mino2


	
	
#"res://" + selected_mino + ".tscn"


#キーを離した時にすこしラグがうまれるようにしたい。
var rug_judL = false
var rug_judR = false

#最初に移動したときにすこしラグが欲しい
#いいかんじ
var first_push_left = true
var first_push_right = true
var first_timerL = 0
var first_timerR = 0


#移動単位
const dist = 30

#ミノの回転角度
var rot_deg = 0

#現在のミノの状態を知ることで接地判定や回転判定ができる。ミノの状態は、ミノの回転とミノの座標によって決まる。
#ミノの回転した後の情報はGlobalに入れておく。ミノの座標はここで取得可能。

var now_mino_low
# Called when the node enters the scene tree for the first time.
func _ready():
	Global.appear_mino = now_mino.to_lower()
	#Iミノだけ一つ下に行ってしまう。
	
	
	# _minoノードがnullでないことを確認

# Called every frame. 'delta' is the elapsed time since the previous frame.
	
			
			
func _process(delta):
	
	ghost_count()
	
	Global.to_ground()
	if(Input.is_action_just_pressed("debug")):
		on_ground()
	
	first_move()
	
	#ここは最初に地面についたかどうかが知りたい→設置までの判定
	#if(!first_ground):
		#if(!can_moveDown()):
			#first_ground = true
		
	if(first_ground):
		var a = 0
				
	
	if(Input.is_action_just_pressed("right_rotation")):
		
		rot_SRS(1)
			
		ghost_count()
		
		
		
	if(Input.is_action_just_pressed("left_rotation")):
		
		rot_SRS(-1)
			
		ghost_count()
		
		
		
		"""
		if(can_rotation_L()):
			rotation_degrees -= 90
			count_rotation = 0
			rot_deg -= 1
			if(rot_deg < 0):
				rot_deg = 3
			
			ghost_count()
			
		"""
	
	
	
	if(!first_push_left):
		first_timerL += 1
		
	if(!first_push_right):
		first_timerR += 1
		
		
	if(rug_judL):
		if(count_deltaL > 2):
			rug_judL = false
			count_deltaL = 0
			
	if(rug_judR):
		if(count_deltaR > 2):
			rug_judR = false
			count_deltaR = 0
	
	
	if(count_delta_soft > 1.5):
		if ( Input.is_action_pressed("soft_drop")):
			if(can_moveDown()):
				position.y += dist
				ghost_count()
				count_delta_soft = 0
				
	if(Input.is_action_just_pressed("hard_drop")):
		var how_down = hard_drop()
		on_ground()
			
		
		
	if(count_deltaL > 1.5 && first_timerL > 4):
		if (Input.is_action_pressed("move_left")):
			if(can_moveL()):
				position.x -= dist
				ghost_count()
				count_deltaL = 0
				
					
		
			
			
	if(count_deltaR > 1.5 && first_timerR > 4):
			
		if (Input.is_action_pressed("move_right")):
			if(can_moveR()):
				position.x += dist
				ghost_count()
				count_deltaR = 0
		
					
	
			
	if Input.is_action_just_released("move_left"):
		rug_judL = true
		first_push_left = true
		count_deltaL = 0
		first_timerL = 0
		
	if Input.is_action_just_released("move_right"):
		rug_judR = true
		first_push_right = true
		count_deltaR = 0
		first_timerR = 0
		
		
	count_deltaL += 1
	count_deltaR += 1
	count_delta_soft += 1
	count_free_fall += 1
	count_rotation += 1
	
	
#ここで移動が可能かを確かめたい。



func first_move():
	if ( Input.is_action_pressed("move_left") && can_moveL()):
		if(first_push_left):
			first_push_left = false
			position.x -= dist
			ghost_count()

			
			
	if ( Input.is_action_pressed("move_right") && can_moveR()) :
		if(first_push_right):
			first_push_right = false
			position.x += dist
			ghost_count()
			

#ここで現在のミノがグリッドにおいてどの位置にあるかを調べたい。
#まず回転については先に処理しているものとする
func now_mino_info(how_rot=0):
		
	var now_mino_list = []
	
	if(now_mino == "L_mino"):
		now_mino_list = tetriminos_integrate[(rot_deg + how_rot) % 4][0].duplicate(true)
		print( tetriminos_integrate[(rot_deg + how_rot) % 4][0].duplicate(true) )
		
	if(now_mino == "J_mino"):
		now_mino_list = tetriminos_integrate[(rot_deg + how_rot) % 4][1].duplicate(true)
		print(tetriminos_integrate[(rot_deg + how_rot) % 4][1].duplicate(true))
		
	if(now_mino == "S_mino"):
		now_mino_list = tetriminos_integrate[(rot_deg + how_rot) % 4][2].duplicate(true)
		print(tetriminos_integrate[(rot_deg + how_rot) % 4][2].duplicate(true))
		
	if(now_mino == "Z_mino"):
		now_mino_list = tetriminos_integrate[(rot_deg + how_rot) % 4][3].duplicate(true)
		print(tetriminos_integrate[(rot_deg + how_rot) % 4][3].duplicate(true))
		
	if(now_mino == "T_mino"):
		now_mino_list = tetriminos_integrate[(rot_deg + how_rot) % 4][4].duplicate(true)
		print(tetriminos_integrate[(rot_deg + how_rot) % 4][4].duplicate(true))
		
	if(now_mino == "O_mino"):
		now_mino_list = tetriminos_integrate[(rot_deg + how_rot) % 4][5].duplicate(true)
		print(tetriminos_integrate[(rot_deg + how_rot) % 4][5].duplicate(true))
		
	if(now_mino == "I_mino"):
		now_mino_list = tetriminos_integrate[(rot_deg + how_rot) % 4][6].duplicate(true)
		print(tetriminos_integrate[(rot_deg + how_rot) % 4][6].duplicate(true))
		
	return now_mino_list
	
func now_mino_pos(now_list):
	
	
	if( !(now_mino == "") ):
		
		
		var grid_x = (position.x+135) / 30 + 1
		var grid_y = (position.y-45) / 30 + 3
		
		for i in range(4):

			now_list[i][0] += grid_x 
			now_list[i][1] += grid_y - 1
			
	return now_list		

#ここはlistを変更するか変更しないか迷う
func can_move(now_list=tetriminos_integrate[(rot_deg) % 4][6].duplicate(true), next_x = 0, next_y = 0):
	
	var list_keep = now_list.duplicate(true)
	
	for i in range(4):
		list_keep[i][0] += next_x
		list_keep[i][1] += next_y
		
	if( !(now_mino == "") ):
		
		for i in range(4):
			
			if(now_list[i][0] < 0 || list_keep[i][0] > 11 || list_keep[i][1] < 0 || list_keep[i][1] > 22):
				return false
				
			if(Global.tetris_grid_keep[ list_keep[i][0] ][ list_keep[i][1] ] > 0):
				print(list_keep)
				print("%%%%%%%%%%%%%%%%%")
				return false

		return true
		
		

func can_moveR():

	var now_list = now_mino_info()
	now_mino_pos(now_list)
	return can_move(now_list, 1, 0)
		
	Global.tetri_minos_inte = Global.tetri_minos_inte_keep


#移動を確かめる
func can_moveL():
	
	var now_list = now_mino_info()
	now_mino_pos(now_list)
	return can_move(now_list, -1, 0)


	Global.tetri_minos_inte = Global.tetri_minos_inte_keep


#落下を確かめる
func can_moveDown():

	var now_list = now_mino_info()
	now_mino_pos(now_list)
	return can_move(now_list, 0, 1)
				
	
	Global.tetri_minos_inte = Global.tetri_minos_inte_keep
	

func can_moveDown_how():

	var now_list = now_mino_info()

	if( !(now_mino == "") ):
		
		now_mino_pos(now_list)
		
		#ここ変更できない？
		for i in range(4):
			now_list[i][1] += 1
		
		"""
		var grid_x = (position.x+135) / 30 + 1
		var grid_y = (position.y-45) / 30 + 3
		
		for i in range(4):

			now_list[i][0] += grid_x
			now_list[i][1] += grid_y
		"""

		var check_fall = true
		var how_fall = 0
		
		while(check_fall):
			for i in range(4):
				if(Global.tetris_grid_keep[ now_list[i][0] ][ now_list[i][1] ] > 0):
					check_fall = false
					break
			
			if(!check_fall):
				break
				
			how_fall += 1
			
			for i in range(4):
				now_list[i][1] += 1
		
		return how_fall


	
var minoGD_mino
var minoGD_posX
var minoGD_posY
var minoGD_rot

#ここで設置したときの処理を行う。
#ミノの種類、座標、回転角を保存した後FIelDから消去するそれはmainの方でやるがそれはGlobalを介する
func on_ground():
	
	var now_list = []
	var mino_count = 0
	
	
	if(now_mino == "L_mino"):
		now_list = tetriminos_integrate[rot_deg][0].duplicate(true)
		mino_count = 2
		
	if(now_mino == "J_mino"):
		now_list = tetriminos_integrate[rot_deg][1].duplicate(true)
		mino_count = 3
		
	if(now_mino == "S_mino"):
		now_list = tetriminos_integrate[rot_deg][2].duplicate(true)
		mino_count = 4
		
	if(now_mino == "Z_mino"):
		now_list = tetriminos_integrate[rot_deg][3].duplicate(true)
		mino_count = 5
		
	if(now_mino == "T_mino"):
		now_list = tetriminos_integrate[rot_deg][4].duplicate(true)
		mino_count = 6
		
	if(now_mino == "O_mino"):
		now_list = tetriminos_integrate[rot_deg][5].duplicate(true)
		mino_count = 7
		
	if(now_mino == "I_mino"):
		now_list = tetriminos_integrate[rot_deg][6].duplicate(true)
		mino_count = 8
		
	
	if( !(now_mino == "") ):

		
		now_mino_pos(now_list)
		
		
		for i in range(4):
				
			Global.tetris_grid_keep[ now_list[i][0] ][ now_list[i][1] ] = mino_count
			
			print(Global.tetris_grid_keep[ now_list[i][0] ][ now_list[i][1] ])
			print("QQQQQQQQQQQQQQQQQQQQQQQQQQQQ")

		
	Global.aaa = true #ここを介してmainでの操作を行う(もっといい方法ない？)


func ghost_count():
	
	for child in _mino_ghost.get_children():
		child.queue_free()
		
	var how_can_fall = can_moveDown_how()
	
	now_mino_low = now_mino.to_lower()
	print(now_mino_low)
	
	var mino_scene = load("res://" + now_mino_low + "_keep.tscn")
	mino2 = mino_scene.instantiate()
	
	_mino_ghost.add_child(mino2)
	var color = mino2.get_modulate()
	color.a = 0.5
	mino2.set_modulate(color)
	
	
	if( !(now_mino_low == "i_mino" || now_mino_low == "o_mino") ):
		
		mino2.position.x += 15
		mino2.position.y -= 15
		
	if(rot_deg == 0):
		mino2.position.y += how_can_fall*30
	
	if(rot_deg == 1):
		mino2.position.x += how_can_fall*30
	
	if(rot_deg == 2):
		mino2.position.y -= how_can_fall*30
	
	if(rot_deg == 3):
		mino2.position.x -= how_can_fall*30
		

#ここでハードドロップの定義
func hard_drop():
	
	var count_down = 0
	
	while(can_moveDown()):
		count_down += 1
		position.y += dist
		
	Global.hold_now = false
	Global.bbb = true
	

#ここではその場で回転することができるかを調べる。
func can_rotation_R():
	
	var now_list = now_mino_info(1)
	
	if(now_mino != "I_mino"):
		
		now_mino_pos(now_list)
		
		return can_move(now_list)

	else:
		return true
		
		
func can_rotation_L():
		
	var now_list = now_mino_info(-1)
	
	if(now_mino != "I_mino"):
		
		now_mino_pos(now_list)
		
		return can_move(now_list)
			
	else:
		return true


#右回転をデフォルトにしている。
#最初にまず他のcan_~~と同じように現在のミノの回転状態を取得し、一に対応させる。
#ここではrot_deg(回転角度)は何も変わらないので変えておく。回転ができないのであれば最後に情報を元に戻す

#参考サイト(図と説明が食い違ってる？)
#https://lets-csharp.com/tetris-cpp-srs/
#以下説明

"""
Iミノ以外の5つのミノにおいて
1
軸を左右に動かす
0が90度（B）の場合は左，-90度（D）の場合は右へ移動
0が0度（A），180度（C）の場合は回転した方向の逆へ移動

2
その状態から軸を上下に動かす
0が90度（B），-90度（D）の場合は上へ移動
0が0度（A），180度（C）の場合は下へ移動

3
元に戻し，軸を上下に2マス動かす
0が90度（B），-90度（D）の場合は下へ移動
0が0度（A），180度（C）の場合は上へ移動

4
その状態から軸を左右に動かす
0が90度（B）の場合は左，-90度（D）の場合は右へ移動
0が0度（A），180度（C）の場合は回転した方向の逆へ移動

"""

#Iミノ以外はうまくいっているはずなのでIミノの場合を考えたい。
func rot_SRS(rot_direction=1):
	
	var count_rot_num = 0
	var now_list = []
	
	now_list = now_mino_info(rot_direction)		
		
	now_mino_pos(now_list)
	
	#-1%4 = -1と出力されたので4を足しておく。
	
	rot_deg += rot_direction + 4
	rot_deg %= 4
	
	rotation_degrees += 90*rot_direction
	
	#これは一応やっている。can_moveではlistが変わらないはずなので
	var now_list_keep = now_list.duplicate(true)
	
	var where = (rot_direction + rot_deg + 4)%4
	
	#ここまででミノの現在位置と回転は終わっているのであとはミノをいろいろ動かしてみて条件を満たすかどうかを考える。
	
	#0の時、その場での回転は終わっているので動かなくてよい。
	if(count_rot_num == 0):
		
		if(can_move(now_list,0,0)):
			pass
		else:
			count_rot_num += 1

		
	#次に左右移動
	#rot_deg→1は左rot_deg→3は右
	#それ以外は回転の逆→rot_direction(右回転が1左回転が-1)
	
	"""ここは最初から"""
	if(count_rot_num == 1):
		
		if(rot_deg == 1 || rot_deg == 3):
			
			if( can_move(now_list, -1*(2-rot_deg), 0) ):
				position.x -= 30*(2-rot_deg)
			
			else:
				count_rot_num += 1
				
		else:
			
			if( can_move(now_list, (where-2), 0) ):
				position.x += 30*(where-2)
			else: 
				count_rot_num += 1
				
	
	#can_moveの引数は(list,移動先のdx、移動先のdy)で上は-1に注意
	#上の移動先から
	#rot_degが1、3の時は上に行く→dy=-1それ以外は+1
	
	"""ここは1の続き"""
	if(count_rot_num == 2):
		
		if(rot_deg == 1 || rot_deg == 3):
			
			if( can_move(now_list,-1*(2-rot_deg),-1) ):
				position.x -= 30*(2-rot_deg)
				position.y -= 30
			
			else:
				count_rot_num += 1
				
		else:
			
			if( can_move(now_list, (where-2), 1) ):
				position.x += 30*(where-2)
				position.y += 30
			else: 
				count_rot_num += 1
			
			
	"""ここは位置をリセットしている"""
	if(count_rot_num == 3):
		
		if(rot_deg == 1 || rot_deg == 3):
			
			if( can_move(now_list,0,2) ):
				position.y += 60
			
			else:
				count_rot_num += 1
				
		else:
			
			if( can_move(now_list, 0, -2) ):
				position.y -= 60
			else: 
				count_rot_num += 1
				
	"""ここは3と続いている"""
	if(count_rot_num == 4):
		
		if(rot_deg == 1 || rot_deg == 3):
			
			if( can_move(now_list,-1*(2-rot_deg),2) ):
				position.y += 60
				position.x -= 30*(2-rot_deg)
			
			else:
				count_rot_num += 1
				
		else:
			
			if( can_move(now_list, (where-2), -2) ):
				position.y -= 60
				position.x += (where-2)*30
			else: 
				count_rot_num += 1
	
	
	"""ここはどれもできなかった場合"""
	if(count_rot_num == 5):
		
		rot_deg -=- rot_direction
		rot_deg += 4
		rot_deg %= 4
		
		rotation_degrees -= 90*rot_direction
	

"""
右回転のやつ
rotation_degrees += 90
ここcount_rotation = 0
rot_deg += 1
if(rot_deg > 3):
rot_deg = 0
				"""		
		
	
