data "aws_organizations_organization" "organization" {}

data "aws_organizations_organizational_units" "root" {
    parent_id = data.aws_organizations_organization.organization.roots[0].id 
}

data "aws_organizations_organizational_units" "ous_depth_1" {
    for_each = toset([for x in data.aws_organizations_organizational_units.root.children : x.id])
    parent_id = each.key
    depends_on = [
        data.aws_organizations_organizational_units.root
    ]
}

data "aws_organizations_organizational_units" "ous_depth_2" {
    for_each = toset([for x in data.aws_organizations_organizational_units.root.children : x.id])
    parent_id = each.key
    depends_on = [
        data.aws_organizations_organizational_units.ous_depth_1
    ]
}

data "aws_organizations_organizational_units" "ous_depth_3" {
    for_each = toset([for x in data.aws_organizations_organizational_units.root.children : x.id])
    parent_id = each.key
    depends_on = [
        data.aws_organizations_organizational_units.ous_depth_2
    ]
}

data "aws_organizations_organizational_units" "ous_depth_4" {
    for_each = toset([for x in data.aws_organizations_organizational_units.root.children : x.id])
    parent_id = each.key
    depends_on = [
        data.aws_organizations_organizational_units.ous_depth_3
    ]
}

locals {
   
    old_new_guardrails_map_list = flatten([
    for i in range(0, length(var.new_maps)) : [
      for pair in setproduct(
        lookup(var.new_maps[i].controls_for_each_org[var.new_maps[i].organizational_unit_name[0]], var.ct_home_region, []),
        var.new_maps[i].organizational_unit_name
      ) :
       { "arn:aws:controltower:${var.ct_home_region}::control/${pair[0]}" = replace(pair[1], "_", " ") }
    ]
  ])

   new_guardrails_map_list = flatten([
    for map_item in var.new_maps : flatten([
      for ou, regions in map_item.controls_for_each_org : [
        for control in lookup(regions, var.ct_home_region, []) :
        { "arn:aws:controltower:${var.ct_home_region}::control/${control}" = replace(ou, "_", " ") }
      ]
    ])
  ])

  



ous_depth_1 = [for x in data.aws_organizations_organizational_units.root.children : x]
ous_depth_2 = flatten([for x in data.aws_organizations_organizational_units.ous_depth_1 : x.children if length (x.children) != 0])

ous_id_to_arn_map = {for ou in concat(local.ous_depth_1 , local.ous_depth_2): ou.id => ou.arn}

ous_name_to_id_map = {for ou in concat(local.ous_depth_1 , local.ous_depth_2): ou.name => ou.id}

ous_name_to_arn_map = {for ou in concat(local.ous_depth_1 , local.ous_depth_2): ou.name => ou.arn}


}

resource "aws_controltower_control" "guardrails" {
    for_each = { for control in local.new_guardrails_map_list : join(":", [keys(control)[0], values(control)[0]]) => [keys(control)[0], values(control)[0]]}
    control_identifier = each.value[0]
    target_identifier = local.ous_name_to_arn_map[each.value[1]]
}

