# Foxpass - VPN

This repo contains a Terraform project that sets up an Ubuntu based VM built by Foxpass to use with their services.
The result is a DNS address that users can use with their Google/Office365 credentials to connect with.

Links:
- [VM built by Foxpass](https://github.com/foxpass/foxpass-ipsec-vpn) on to AWS
- [Official doc for the VPN server](https://docs.foxpass.com/docs/set-up-a-vpn)
 

## Prerequisites

- [Terraform](https://terraform.io) ~> v0.12.0
- AWS Account [with credentials installed locally](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html)

## Using/Installing

### 1. Enable usage of AMI

This project uses the prebuilt AMI's [(source)](https://github.com/foxpass/foxpass-ipsec-vpn) from Foxpass.
You must accept these terms and conditions otherwise AWS will not allow you to launch an instance.

While logged in to the target AWS account:
- Go to https://aws.amazon.com/marketplace/pp?sku=cdsjmv5modgffkrgs4bi5ogtn
- Click subscribe (free)
- Click accept terms and conditions

### 2. Clone this repository:
```bash
# Note: The following command is using HTTPS. You can use SSH.
git clone https://github.com/madetech/vpn.git
```

### 3. Populate `variables.tf` file
```bash
cp terraform.tfvars.example terraform.tfvars
```
Edit `variables.tf` using your preferred editor using the example below as a guide.

### Variables explanation
#### `dns_primary` / `dns_secondary` 
Can optionally be changed to your desired DNS provider
#### `public_dns_name`
If you want to create a domain name that points to the public IP address of the VPN, set the domain name here. 
Once terraform is run it will output a set of DNS servers that you can use to point your domain/subdomain using an NS server entry
#### `foxpass_api_key`
This must be set for the server to be able to authenticate users,
your Foxpass admin can create a new API key here -> https://console.foxpass.com/settings/
#### `shared_psk`
This is the first layer shared password that all users must enter before entering their user creds.
***This should be a long secure password.***
#### `ssh_public_key`
An ssh public key used to ssh into the VM for maintenance purposes: [guide](https://www.digitalocean.com/community/tutorials/how-to-set-up-ssh-keys--2)

###  4. Initialize Terraform
The [state.tf](./state.tf) sets up and configures Terraform to save its internal state remotely in AWS.

There are 2 options available:
- Comment out this entire file (Warning: **Will result in changes only being possible from your current machine**)  
- Configure and bootstrap the state file (instructions included below) 


<hr/>

#### **When running in a new account**
- Comment out the `backend` block in the [state.tf](./state.tf) (this is to bootstrap the initial run)
- Rename the 2 usages of the bucket name `foxpass-vpn-project-state` to something unique
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
# Download dependencies and set up state 
terraform init
# show and run setup (this step requires the user to type `yes` midway though)
terraform apply
```
Terraform should now output the DNS name server addresses as well as public IP that can be used for the VPN like so (these will differ to yours)
```hcl-terraform
Outputs:

dns_nameservers = [
  "ns-1111.awsdns-66.org",
  "ns-1112.awsdns-67.co.uk",
  "ns-1113.awsdns-68.com",
  "ns-1114.awsdns-69.net",
]
instance_ip_address = 192.0.2.0

```

<hr/>

#### **When running in a new account and using remote state**
-  Uncomment the `backend` block that we previously commented out
- Rerun `terraform init` and answer `yes` when prompted to migrate the state

<hr/>

## Contributing
PRs are welcome! Please open an issue before submitting any large changes.
