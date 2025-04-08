extends BaseAction

class_name ProjectileAction


@export var flight_speed: float
@export var max_pierce_count: int
var has_pierced_count: int = 0
@export var collision_shape: CollisionShape2D
@export var distance_travelled: float = 0;
@export var trajectory: Vector2
@export var target: Node
@export var speed: float
@export var time_since_fire: int = 0
@export var hit_enemies: Array = [Node]
@export var continue_trejectory_distance: float = 10 # we need to decide when we're close enough to an enemy to not sort of weirdly loop back and then set a trajectory forever

func execute(_action_resource: ActionResource, target_method := TargetMethods.CLOSEST):
	super.execute(_action_resource, target_method)
	has_pierced_count = 0
	target = null
	max_pierce_count = action_resource.projectile_settings.max_pierce_count
	if not caster or not is_instance_valid(caster):
		push_error("ProjectileAction: Caster is not set or invalid!")
		finish_action() # Clean up immediately
		return

	if not collision_shape or not action_resource:
		push_error("missing visuals, collision shape or the passed through action resource on the projectile action")
		finish_action()
		return
	
	var caster_pos = caster.global_position
	target = NodeFinder.find_closest("targets_for_players", caster.global_position, 1000, [], NodeFinder.ExclusionType.IGNORE)

	if not target:
		push_error("we couldnt find a target for the Arrow")
		finish_action()
		return

	trajectory = (target.global_position - caster_pos).normalized()
	self.global_position = caster_pos + trajectory * 10

func _physics_process(delta):
	distance_travelled += delta * speed
	if distance_travelled > action_resource.projectile_settings.travel_distance:
		finish_action()

	if has_pierced_count >= max_pierce_count:
		finish_action()
	
	self.global_position += trajectory * action_resource.projectile_settings.flight_speed * delta
	self.rotation = trajectory.angle() + PI / 2


func _apply_effect(target: Node):
	if target.has_method("take_damage"):
		if action_resource.damage > 0:
			target.take_damage(action_resource.damage)
	else: push_error("doesnt have take damage option")


func _on_body_entered(body):
	print("on body entered")
	if body.is_in_group("targets_for_players") and body not in hit_enemies:
		_apply_effect(body)
		has_pierced_count += 1
		hit_enemies.append(body)
		if body == target:
			target = null
