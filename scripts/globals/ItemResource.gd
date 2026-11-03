extends Resource
class_name ItemResource

enum Type { KEY, CONSUMABLE, EQUIPMENT, AMMO }

@export var name: String = ""
@export var description: String = ""
@export var scene_3d: PackedScene          # modelo girando no inventário
@export var spin_speed: float = 0.5
@export var initial_rotation: Vector3 = Vector3.ZERO

@export_group("Uso")
@export var type: Type = Type.KEY
@export var heal_amount: int = 0           # CONSUMABLE

@export_group("Equipamento")
enum EquipKind { NONE, LIGHT, WEAPON_RANGED, WEAPON_MELEE }

@export var equip_scene: PackedScene
@export var equip_kind: EquipKind = EquipKind.NONE
