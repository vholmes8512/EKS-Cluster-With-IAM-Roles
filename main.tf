#Deploy an EKS Cluster Using Terraform
#Contributor: Vincent Holmes

#Define iam role for EKS Cluster
resource "aws_iam_role" "eks_cluster_role1" {
  name = "eksClusterRole${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

#local variable
variable "environment" {
    description = "development environment"
    type = string
    default = "dev"
}

#Define iam role for EKS Node Group
resource "aws_iam_role" "eks_node_group_role1" {
  name = "eksNodeGroupRole${var.environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_attachment1" {
  role       = aws_iam_role.eks_cluster_role1.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "eks_node_group_role_attachment1" {
  role       = aws_iam_role.eks_node_group_role1.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

#Define EKS Cluster
resource "aws_eks_cluster" "eks_cluster1" {
  name     = "terraform-eks-cluster1${var.environment}"
  role_arn = aws_iam_role.eks_cluster_role1.arn

  vpc_config {
    subnet_ids = ["subnet-01ba912c33254af74", "subnet-045aea77e15c4ac89"]
  }
}

#Define EKS Node Group
resource "aws_eks_node_group" "eks_node_group1" {
  cluster_name    = aws_eks_cluster.eks_cluster1.name
  node_group_name = "terraform-node-group${var.environment}"
  node_role_arn   = aws_iam_role.eks_node_group_role1.arn
  subnet_ids      = ["subnet-01ba912c33254af74", "subnet-045aea77e15c4ac89"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  instance_types = ["t3.medium"]
}
