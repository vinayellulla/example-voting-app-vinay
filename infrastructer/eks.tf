resource "aws_eks_cluster" "solid_cluster" {
  name     = var.project_name
  role_arn = aws_iam_role.cluster_role.arn
  version  = "1.29"
  vpc_config {

    subnet_ids = [
      aws_subnet.sub1.id, aws_subnet.sub2.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.cluster_role_attachment]
}

resource "aws_eks_node_group" "solid_node_group" {

  cluster_name    = aws_eks_cluster.solid_cluster.name
  node_group_name = "voting-app-node-group"
  node_role_arn   = aws_iam_role.node_group_role.arn
  subnet_ids      = [aws_subnet.sub1.id, aws_subnet.sub2.id]

  instance_types = ["t3.medium"]

  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_role_attachment,
    aws_iam_role_policy_attachment.node_worker_policy,
    aws_iam_role_policy_attachment.node_ecr_policy,
    aws_iam_role_policy_attachment.node_cni_policy
  ]
}
