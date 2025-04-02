extends Resource
class_name ActionResource

#enum for different tags

enum TAGS {
	PROJECTILE,
	AURA,
	PET,
	GROUNDTARGET,
	LINETARGET,
	SUPPORT,
}

enum TargetOptions {
	closest, highest_health, random
}

@export var name: String
@export var tags: Array[TAGS]
@export var damage: int
@export var circle_radius: int
@export var collidable: bool = true
@export var sound_file : AudioStream
@export var mana_cost: int
@export var scene_path: String
@export var cooldown: float = 1	
