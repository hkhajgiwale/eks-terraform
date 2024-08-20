data "aws_iam_policy_document" "eks_cluster_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "eks_cluster" {
  name               = "EKSClusterRole"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy_document" "eks_worker_node_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}
resource "aws_iam_role" "eks_worker_node" {
  name               = "EKSWorkerNodeRole"
  assume_role_policy = data.aws_iam_policy_document.eks_worker_node_assume_role.json
}


resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_worker_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_cni_policy" {
  role       = aws_iam_role.eks_worker_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_ec2_container_registry_policy" {
  role       = aws_iam_role.eks_worker_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy_document" "bastion_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "bastion_role" {
  name               = "BastionInstanceRole"
  assume_role_policy = data.aws_iam_policy_document.bastion_assume_role.json
}

resource "aws_iam_role_policy_attachment" "bastion_ssm_policy" {
  role       = aws_iam_role.bastion_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM instance profile for the bastion instance
resource "aws_iam_instance_profile" "bastion_iam_instance_profile" {
  name = "bastion-instance-profile"
  role = aws_iam_role.bastion_role.name
}

data "aws_iam_policy_document" "bastion_eks_permissions" {
  statement {
    effect = "Allow"

    actions = [
      "eks:*"
    ]

    resources = [
      "*"
    ]
  }
}

resource "aws_iam_policy" "bastion_eks_policy" {
  name   = "BastionEKSAccessPolicy"
  policy = data.aws_iam_policy_document.bastion_eks_permissions.json
}

resource "aws_iam_role_policy_attachment" "bastion_eks_policy_attachment" {
  policy_arn = aws_iam_policy.bastion_eks_policy.arn
  role       = aws_iam_role.bastion_role.name
}