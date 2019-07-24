variable dns_primary {
  type        = string
  default     = "1.1.1.1"
  description = "Can optionally changed to your desired dns provider"
}
variable dns_secondary {
  type        = string
  default     = "1.0.0.1"
  description = "Can optionally changed to your desired dns provider"
}
variable public_dns_name {
  type        = string
  description = "If you want to create a domain name that points to the public ip of the vpn set the domain name here. Once terraform is run it will output a set of dns servers that you can use to point your domain/subdomain using a NS server entry"
}
variable foxpass_api_key {
  type        = string
  description = "This must be set for the server to be able to authenticate users your Foxpass admin can create a new api key here -> https://console.foxpass.com/settings/"
}
variable shared_psk {
  type        = string
  description = "This is the first layer shared password that all users must enter before entering there user creds."
}
variable ssh_public_key {
  type        = string
  description = "A ssh public key used to ssh into the VM for maintenance purposes. https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2"
}