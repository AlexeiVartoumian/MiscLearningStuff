

output "ous_id_to_arn_map" {
    value = local.ous_id_to_arn_map
    description = "map from ou id to ou arn for org"
}

output "ous_name_to_id_map" {
    value = local.ous_name_to_id_map
    description = "map from ou name to ou id for the whole organisation"
}

output "guardrails_list" {
    value  = local.new_guardrails_map_list
    description = "Guardrails list"
}

