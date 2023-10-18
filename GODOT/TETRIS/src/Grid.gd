extends ColorRect





"""

extends CharacterBody2D

const ANIM_SPEED = 7 # アニメーション速度
const GRAVITY = 45 # 重力
const JUMP_POWER = 1000 # ジャンプ力
const MOVE_SPEED = 300 # 移動速度.
const MAX_JUMP_CNT = 2 # 2段ジャンプまで可能.


@onready var _spr = $Player # スプライト

var _tAnim:float = 0 # アニメーションタイマー.

var _velocity := Vector2.ZERO # 移動ベクトル.

var _is_jumping = false # ジャンプ中かどうか.
var _cnt_jump = 0 # ジャンプ回数.

var _speed := MOVE_SPEED # 移動速度.
#:=は静的に型をつけるらしいvar num := 10はvar num: int = 10と同じらしい


const SPEED = 300.0
const JUMP_VELOCITY = -400.0


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


func _process(delta: float) -> void:
	# アニメーションの更新.
	_update_anim(delta)
	
func _update_anim(delta:float) -> void:
	_tAnim += delta
	
	if _is_jumping:
		
		if _cnt_jump == 1:
			_spr.rotation_degrees += 2000 * delta
		else:
			_spr.rotation_degrees = 0
		# ジャンプ中
		_spr.frame = 2
		return
		
	_spr.rotation_degrees = 0
	
	var t = int(_tAnim * ANIM_SPEED) % 2
	var tbl = [2, 3] # 走りアニメーションしか使わない.
	_spr.frame = tbl[t]

func _physics_process(delta):
	velocity.x = _speed
	if position.y > 680:
		
		velocity.y = -1000
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
		_is_jumping = true
	else :
		_is_jumping = false
		_cnt_jump = 0 # ジャンプ回数をリセットする.
		

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	#この部分はプレイヤーを自分で自由に操作するときの話で、今回は勝手に右に動くスクロール型)なのでなし。

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

		
	
	if _cnt_jump < MAX_JUMP_CNT:
		if Input.is_action_just_pressed("ui_accept"):
			# ジャンプ.
			velocity.y = JUMP_VELOCITY
			_cnt_jump += 1

	move_and_slide()
	
	
	
	
	
	
	
	extends Node2D



var obj_floor = preload("res://fllor.tscn") # 床オブジェクト
# Called when the node enters the scene tree for the first time.

const CAMERA_POS_Y = 320 # カメラの位置(Y).
const CAMERA_OFS_X = 400 # プレイヤーからのオフセット
const FLOOR_INTERVAL = 64 # 足場は 64px 単位で登場する.
const SCREEN_W = 1024 # 画面の幅.

@onready var _player = $Player # プレイヤー.
@onready var _camera = $Camera2D # カメラ.
@onready var _field_mgr = $FieldMgr # フィールド管理.

var _prev_x:float = 0 # 前回の座標(X)
var _prev_y:float = 320 # 前回の座標(Y)
var _cnt_create:int = 0 # 足場を生成した回数.
var _timer:float = 0 # 経過時間.

func _ready():
	_prev_x = _player.position.x


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# カメラをプレイヤーに追従させる.
	_camera.position.x = _player.position.x + CAMERA_OFS_X
	
	# 足場の生成チェック.
	_check_floor()
	
	
func _check_floor() -> void:
	# FLOOR_INTERVALの単位になるようにする.
	var prev = floor(_prev_x / FLOOR_INTERVAL) * FLOOR_INTERVAL # 前回.
	var now = floor(_player.position.x / FLOOR_INTERVAL) * FLOOR_INTERVAL # 現在値.

	if prev != now:
		# 出現タイミングになった.
		_cnt_create += 1 # 生成カウンタをアップする.
		
		if _cnt_create%9 == 8:
			# 出現座標(Y)を更新する.
			var y = _prev_y + (randi()%8 - 4) * 32
			if y < 200:
				y = 200 # 200よりも上にならないようにする
			if y > 540:
				y = 540 # 540よりも下にならないようにする
			_prev_y = y
		if _cnt_create%9 < 6:
			# (0〜5)なら床出現.
			_create_floor(now, _prev_y)
	
	# 今回のプレイヤー位置を保存しておく.
	_prev_x = _player.position.x
	
# 足場を生成する.
func _create_floor(px:float, py:float) -> void:
	var obj = obj_floor.instantiate()
	obj.position.x = px + SCREEN_W
	obj.position.y = py
	_field_mgr.add_child(obj)
	
	
	
	
	
	
	
	

	 """
