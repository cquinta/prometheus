locals {
    region = {
        "production" = "us-east-2"
        "stating" = "us-east-1"
        "test" = "us-west-1"
        "dev" = "us-west-2"
    }
sg_group_rule = {
    testing1 = {
        cidr_blocks = ["0.0.0.0/0"]
        port = "7070"
        protocol = "tcp"
    },
    testing2 = {
        cidr_blocks = ["0.0.0.0/0"]
        port = "6060"
        protocol = "tcp"
    }
}
}