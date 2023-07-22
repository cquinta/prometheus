provider "aws" {
  region = "us-east-1"
}

resource "aws_eks_cluster" "default" {
  name = "my-eks-cluster"
}

resource "aws_eks_node_group" "default" {
  cluster_name = aws_eks_cluster.default.name
  node_role_arn = aws_iam_role.default.arn
  node_type = "t2.micro"
  desired_capacity = 3
}

resource "aws_iam_role" "default" {
  name = "my-eks-node-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "default" {
  role_name = aws_iam_role.default.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}