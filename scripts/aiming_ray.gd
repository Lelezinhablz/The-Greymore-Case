class_name AimingRay extends Node3D

func find_closest_target() -> AimTarget:
	var closest_distance_found := INF
	var closest_target: AimTarget = null
	
	var targets: Array[Node] = get_tree().get_nodes_in_group("aim_targets")
	
	for target in targets:
		if not target is AimTarget:
			continue
			
		var distance_to_target = global_position.distance_to(target.global_position)
		
		if distance_to_target < closest_distance_found:
			closest_distance_found = distance_to_target
			closest_target = target as AimTarget
			
	return closest_target
