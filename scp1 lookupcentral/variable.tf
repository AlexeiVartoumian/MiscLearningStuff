
variable "ct_home_region" {
    description = "reguin that will be sipplied at run time"

    type = string
    default = "eu-west-2"
}


variable "new_maps" {

    description = "central lookup for controls"
    type = list(object({
        controls_for_each_org = map( map(list( string))) 
        organizational_unit_name = list(string)
    }))
}


