locals {
  account_id = data.aws_caller_identity.current.account_id
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion_key"
  public_key = file("${path.module}/files/bastion_key.pub")
}

resource "aws_instance" "bastion_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  subnet_id              = element(aws_subnet.public[*].id, 0)
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  key_name             = aws_key_pair.bastion_key.key_name
  iam_instance_profile = aws_iam_instance_profile.bastion_iam_instance_profile.name

  user_data = file("${path.module}/templates/user_data.sh")

  tags = {
    Name = "BastionHost"
  }
}

data "template_file" "aws_auth_configmap" {
  template = file("${path.module}/templates/aws-auth-configmap.yaml.tpl")

  vars = {
    account_id = local.account_id
    worker_node_role_arn = aws_iam_role.eks_worker_node.arn
  }
  depends_on = [aws_eks_cluster.eks_cluster]
}


resource "null_resource" "upload_aws_auth" {
  provisioner "file" {
    content     = data.template_file.aws_auth_configmap.rendered
    destination = "/home/ubuntu/aws-auth-configmap.yaml"

    connection {
      type        = "ssh"
      host        = aws_instance.bastion_instance.public_ip
      user        = "ubuntu"
      private_key = file("${path.module}/files/bastion_key")
    }
  }
  depends_on = [aws_instance.bastion_instance, aws_eks_cluster.eks_cluster]
}

resource "null_resource" "apply_aws_auth" {
  provisioner "remote-exec" {
    inline = [
      "export AWS_ACCESS_KEY_ID=${var.aws_access_key_id}",
      "export AWS_SECRET_ACCESS_KEY=${var.aws_secret_access_key}",
      # Set the Kubernetes context
      "aws eks update-kubeconfig --name ${aws_eks_cluster.eks_cluster.name} --region us-east-1",
      "kubectl apply -f /home/ubuntu/aws-auth-configmap.yaml -n kube-system",
    ]

    connection {
      type        = "ssh"
      host        = aws_instance.bastion_instance.public_ip
      user        = "ubuntu"
      private_key = file("${path.module}/files/bastion_key")
    }
  }

  depends_on = [null_resource.upload_aws_auth, aws_eks_cluster.eks_cluster]
}
