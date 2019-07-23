variable dns_primary {
  type    = string
  default = "1.1.1.1"
}
variable dns_secondary {
  type    = string
  default = "1.0.0.1"
}
variable public_dns_name {
  type = string
}
variable "foxpass_api_key" {
  type = string
}
variable "shared_psk" {
  type = string
}
variable "ssh_public_key" {
  type = string
}