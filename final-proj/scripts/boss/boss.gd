# boss.gd
# 适用于使用 AnimatedSprite2D 的简化 Boss 脚本
extends CharacterBody2D

# --- 状态枚举 / State Enum ---
enum State {
	IDLE,               # 待机 / Idle
	PURSUIT,            # 追踪/移动 / Pursuit/Movement
	ATTACK_1,           # 组合技 (使用 attack_1 动画) / Combo Attack (Uses attack_1 animation)
	ATTACK_RUSH,        # 突进攻击 (使用 rush_attack 动画) / Rush Attack (Uses rush_attack animation)
	HURT                # 受伤 / Hurt
}

# --- 属性和设置 / Properties and Settings ---

# 玩家/追踪相关 / Player/Tracking
@export var player_path: NodePath          # 玩家节点的路径 / Path to the player node
var player: CharacterBody2D
@export var detection_range: float = 600.0   # 追踪范围（像素） / Detection range (pixels)
@export var movement_speed: float = 200.0    # 追踪时的移动速度 / Movement speed during pursuit
@export var rush_speed: float = 1200.0       # 突进攻击的速度 / Speed for the rush attack
@export var speed := 50
@onready var navigation_agent_2d: NavigationAgent2D = $Navigation/NavigationAgent2D
# 生命周期 / Lifecycle
var current_hp: float = 1000.0 # Boss 的当前生命值 / Boss's current health

# 状态机和计时器 / State Machine and Timers
var current_state: State = State.IDLE
var attack_timer: float = 0.0
@export var attack_cooldown: float = 3.0    # 攻击间隔 / Attack cooldown

# 引用子节点 / Child Node References (确保节点路径正确)
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D # [❗ 关键] 动画精灵节点 / Animated Sprite Node
@onready var combo_area: Area2D = $AttackAreas/ComboHitbox 
@onready var rush_area: Area2D = $AttackAreas/RushHitbox    

# --- Godot 内置函数 / Godot Built-in Functions ---

func _ready():
	# 确保玩家节点路径有效 / Ensure player node path is valid
	if not has_node(player_path):
		push_error("Player node path is invalid!")
		set_process(false)
		return
		
	player = get_node(player_path)
	
	# 检查 AnimatedSprite2D 节点是否已找到 / Check if AnimatedSprite2D node was found
	if animated_sprite:
		animated_sprite.animation_finished.connect(_on_animation_finished)
	else:
		push_error("Error: Could not find AnimatedSprite2D node. Check the scene path.")
		set_process(false)
		return

	set_state(State.IDLE)
	
func _physics_process(delta):
	# Core: Handle movement based on current state
	match current_state:
		State.IDLE, State.PURSUIT:
			handle_movement_and_tracking(delta)
			check_attack_cooldown(delta)
		State.ATTACK_RUSH:
			# Maintain high speed during rush
			pass
		_: # Stop movement during all attack and non-movement states
			velocity = Vector2.ZERO
	
	var direction = to_local(navigation_agent_2d.get_next_path_position()).normalized()
	velocity = direction * speed
	move_and_slide()

func _on_timer_tuneiyt() -> void:
	navigation_agent_2d.target_position = player.position
	pass
	
# State Machine Transition Function

func set_state(new_state: State):
	if current_state == new_state:
		return
		
	# Cleanup logic when exiting current state
	match current_state:
		State.ATTACK_1:
			combo_area.monitoring = false 
		State.ATTACK_RUSH:
			rush_area.monitoring = false  

	current_state = new_state
	
	# 进入新状态的逻辑 / Logic when entering new state
	match new_state:
		State.IDLE:
			animated_sprite.play("idle")
		State.PURSUIT:
			animated_sprite.play("walk")
			movement_speed = 200.0
		State.ATTACK_1:
			animated_sprite.play("attack_1") 
			handle_attack_1_init()
		State.ATTACK_RUSH:
			animated_sprite.play("rush_attack")
			handle_rush_attack_init()
		State.HURT:
			animated_sprite.play("hurt")

# --- 核心机制：自动追踪和移动 / Core Mechanism: Auto-Tracking and Movement ---

func handle_movement_and_tracking(delta):
	var distance_to_player = global_position.distance_to(player.global_position)
	
	if distance_to_player > detection_range:
		# 玩家在范围外：待机 / Player outside range: Idle
		set_state(State.IDLE)
		velocity = Vector2.ZERO
		return
	
	# 玩家在范围内：追踪 / Player in range: Pursuit
	if current_state != State.PURSUIT:
		set_state(State.PURSUIT)

	# 1. 计算方向向量 / Calculate direction vector
	var direction = (player.global_position - global_position).normalized()
	
	# 2. 更新移动速度 / Update movement speed
	velocity = direction * movement_speed
	
	# 3. 翻转 Boss 方向 / Flip Boss direction
	if direction.x > 0:
		animated_sprite.flip_h = false # 使用 AnimatedSprite2D 的 flip_h 属性
	elif direction.x < 0:
		animated_sprite.flip_h = true

# --- 攻击计时和选择 / Attack Timing and Selection ---

func check_attack_cooldown(delta):
	attack_timer += delta
	
	if attack_timer >= attack_cooldown and current_state == State.PURSUIT:
		attack_timer = 0.0
		# 靠近时才攻击 / Attack only when close
		if global_position.distance_to(player.global_position) < 150:
			select_attack()

func select_attack():
	# 攻击选择：随机选择 / Randomly select between Attack 1 and Rush Attack
	if randf() < 0.5: # 50% 概率攻击 1 / 50% chance Attack 1
		set_state(State.ATTACK_1)
	else: # 50% 概率突进 / 50% chance Rush Attack
		set_state(State.ATTACK_RUSH)

# --- 伤害处理 / Damage Handling ---

func take_damage(damage: float):
	current_hp -= damage
	set_state(State.HURT) 
	
	# TODO: 添加 Boss 死亡逻辑，例如: if current_hp <= 0: queue_free()

# --- 攻击实现细节 / Attack Implementation Details ---

# 1. 攻击 1 (组合技) / Attack 1 (Combo)
func handle_attack_1_init():
	# 启用伤害区域，其持续时间由动画决定 / Enable the hitbox
	combo_area.monitoring = true
	# 动画结束时，_on_animation_finished 将关闭 hitbox 并返回 PURSUIT

# 2. 突进攻击 / Rush Attack
func handle_rush_attack_init():
	# 立即锁定方向并突进 / Immediately lock direction and rush
	var rush_direction = (player.global_position - global_position).normalized()
	velocity = rush_direction * rush_speed 
	
	rush_area.monitoring = true
	
	# 突进持续 0.3 秒后结束突进 / End rush after 0.3 seconds
	await get_tree().create_timer(0.3).timeout
	
	# 突进结束后，速度归零并返回追踪 / After rush, zero velocity and return to pursuit
	velocity = Vector2.ZERO
	set_state(State.PURSUIT)

# --- 信号处理 / Signal Handling ---

# 处理 AnimatedSprite2D 动画播放结束事件 / Handles the AnimatedSprite2D animation finished event
func _on_animation_finished():
	var anim_name = animated_sprite.animation
	
	# 处理攻击 1 伤害关闭 / Handle Attack 1 hitbox disabling
	if anim_name == "attack_1":
		combo_area.monitoring = false
		set_state(State.PURSUIT)
		
	# 处理受伤动画结束 / Handle Hurt animation end
	elif anim_name == "hurt":
		set_state(State.PURSUIT)
		
