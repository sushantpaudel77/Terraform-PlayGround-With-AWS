variable "vpc_config" {
  description = "To get the CIDR & Name of VPC from User"
  type = object({
    cidr_block = string
    name       = string
  })
  validation {
    condition     = can(cidrnetmask(var.vpc_config.cidr_block))
    error_message = "Invalid CIDR Format - ${var.vpc_config.cidr_block}"
  }
}

variable "subnet_config" {
  description = "Get the CIDR & AZ for the subnets"
  type = map(object({
    cidr_block = string
    azs        = string
    public = optional(bool, false)
  }))
  validation {
    # Sub1 = {cidr=..} sub2 = {cird=..}, [true, true, false]
    condition     = alltrue([for config in var.subnet_config : can(cidrnetmask(config.cidr_block))])
    error_message = "Invalid CIDR Format in one of the subnets - ${join(", ", [for k, v in var.subnet_config : v.cidr_block])}"
  }
}
