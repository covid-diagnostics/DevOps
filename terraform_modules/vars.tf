variable "cidr" {
  description = "cidr"
  default     = "10.10.0.0/16"
}

variable "azs" {
  type    = list(string)
  default = ["eu-west-1a", "eu-west-1b"]
}
variable "name" {
  default = ""
}