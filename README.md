# Foxpass - VPN

This repo contains a terraform project that setups a ubuntu based VM built by Foxpass to use with there services.
The end result is a dns address that users can use there google/office365 creds to connect to.

Links:
- [VM built by Foxpass](https://github.com/foxpass/foxpass-ipsec-vpn) on to AWS
- [Official doc for the vpn server](https://docs.foxpass.com/docs/set-up-a-vpn)
 

## Prerequisites

- [Terraform](https://terraform.io) ~> v0.12.0
- AWS Account [with credentials installed locally](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

## Using/Installing

### 1. Clone this repository:
```bash
# Note: The following command is using HTTPS. You can use SSH.
git clone https://github.com/madetech/vpn.git
```

### 2. Populate a `variables.tf` file
```bash
cp variables.tf.example variables.tf
```
Edit `variables.tf` using your preferred editor using doc blow as a guide

### Variables explanation
#### `dns_primary` / `dns_secondary` 
can optionally changed to your desired dns provider
#### `public_dns_name`
If you want to create a domain name that points to the public ip of the vpn set the domain name here. 
Once terraform is run it will output a set of dns servers that you can use to point your domain/subdomain using a NS server entry
#### `foxpass_api_key`
This must be set for the server to be able to authenticate users
your Foxpass admin can create a new api key here -> https://console.foxpass.com/settings/
#### `shared_psk`
This is the first layer shared password that all users must enter before entering there user creds.
***This should be a long secure password.***
#### `ssh_public_key`
A ssh public key used to ssh into the VM for maintenance purposes. [guide](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2)

###  3. Initialise Terraform
The [state.tf](./state.tf) sets up and configures terraform to save is internal state remotely in aws.

There are 2 options available:
- Comment out this entire file (Warning: **Will result in changes only being possible from your current machine**)  
- Configure and bootstrap the state file (instructions included below) 


<hr/>

#### **When running in a new account**
- Comment out the "backend" block in the [state.tf](./state.tf) (this is to bootstrap the first time run)
- Rename the 2 usages of the bucket name "foxpass-vpn-project-state" to something unique
```hcl-terraform
terraform {
  required_version = "~> 0.12.0"

//  backend "s3" {
//    //    dynamodb_table = "not used see https://www.terraform.io/docs/backends/types/s3.html if you want to enable"
//    bucket  = "foxpass-vpn-project-state"
//    encrypt = true
//    region  = "eu-west-2"
//    key     = "terrafrom/state/v2/global"
//  }
}
```

<hr/>

```bash
# Download deps and setup state 
terrafrom init
# show and run setup (this step requires the user to type `yes` midway though)
terrafrom apply
```
Terraform should now output the dns name server addresses as well as public ip that can be used for the vpn like so
```hcl-terraform

```

<hr/>

#### **When running in a new account and using remote state**
- Now UnComment out the "backend" block that we previously commented out
- Rerun `terraform init` and answer `yes` when prompted to migrate the state

<hr/>

## Contributing
PR's welcome! (Please open a issue before submitting any large changes) 