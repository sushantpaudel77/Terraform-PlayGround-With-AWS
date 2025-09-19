terraform {

}

# Number List
variable "num_list" {
  type    = list(number)
  default = [1, 2, 3, 4, 5]
}

variable "person_list" {
  type = list(object({
    fname = string
    lname = string
  }))
  default = [{
    fname = "john"
    lname = "doe"
    }, {
    fname = "alice"
    lname = "doe"
  }]
}

variable "map_list" {
  type = map(number)
  default = {
    "one"   = 1
    "two"   = 2
    "three" = 3
  }
}

# Calculations
locals {
  mul = 2 * 2
  add = 2 + 2
  eq  = 2 != 3

  # double the list
  double = [for num in var.num_list : num * 2]

  # Odd no only
  odd = [for num in var.num_list : num if num % 2 != 0]

  # Odd and Even
  oddOrEven = [for num in var.num_list : num % 2 == 0 ? "even" : "odd"]

  # To get only fname from person list
  fname_list = [for person in var.person_list : person.fname]

  lname_list = [for person in var.person_list : person.lname]

  # Work with map
  map_info1 = [for key, value in var.map_list : key]
  map_info2 = [for key, value in var.map_list : value * 2]

  double_map = { for key, value in var.map_list : key => value * 2 }
}

output "output" {
  value = local.double_map
}
