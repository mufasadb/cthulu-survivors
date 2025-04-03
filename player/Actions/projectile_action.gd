extends BaseAction

class_name ProjectileAction


@export var flight_speed: float
@export var max_pierce_count: int
var has_pierced_count: int = 0
@export var collision_shape: CollisionShape2D
@export var travel_distance: float

func execute(target_method:= TargetMethods.CLOSEST,action_resource: ActionResource):
	if not caster or not is_instance_valid(caster):
		push_error("ProjectileAction: Caster is not set or invalid!")
		finish_action() # Clean up immediately
		return

	if not visuals:
		push_error("ProjectileAction: node2d node named 'Visuals' not found!")
		finish_action()
		return

	if not collision_shape:
		push_error("ProjectileAction: CollisionShape2D node named 'CollisionShape' not found!")
		finish_action()
		return

	if not action_resource:
		push_error("ProjectileAction: ActionResource is not set or invalid!")
		finish_action()
		return
	if not action_resource.flight_speed and action_resource.max_pierce_count and action_resource.travel_distance:
		push_error("some of the projectile settings are missing from " + action_resource.action_name)
		finish_action()
		return
	var target = NodeFinder.find_closest("targets_for_players", caster.global_position, 1000, [], NodeFinder.ExclusionType.IGNORE)
	