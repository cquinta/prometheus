provider "aws" {
    region = "us-east-2"
}

terraform {
    backend "s3" {
        bucket = "terraform-cquinta"
        key = "exemplo-tfstates-terraform"
        region = "us-east-1"
    }
}

module "produto" {
    source = "git::https://github.com/cquinta/terraform-module-template.git"
    name = "produto"
    enable_sg = true
    ingress_ports = [80,443]
}

output "ip_address" {
    value = module.produto.ip_address
}