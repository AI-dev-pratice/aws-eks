resource "aws_eks_cluster" "eks-cluster" {
  name     = "${var.project}-${var.environment}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = "1.33"
  vpc_config {
    subnet_ids = flatten([aws_subnet.public_subnet[*].id], [aws_subnet.private_subnet[*].id])
  }

  tags = merge(
    { Name = "${var.project}_${var.environment}_eks_cluster" },
    var.common_tags
  )

}

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project}-${var.environment}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(
    { Name = "${var.project}_${var.environment}_eks_cluster_role" },
    var.common_tags
  )

}

resource "aws_iam_role_policy_attachment" "cluster_role_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"

}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks-cluster.name
  node_group_name = "${var.project}-${var.environment}-eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = aws_subnet.public_subnet[*].id

  depends_on = [aws_iam_role_policy_attachment.cluster_role_attachment]

  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_max_size
    min_size     = var.node_group_min_size
  }
  update_config {
    max_unavailable = 1
  }

  ami_type       = "AL2_x86_64"
  disk_size      = "20"
  capacity_type  = "on_demand"
  instance_types = [var.node_group_instance_type]

}

resource "aws_iam_role" "worker_node_role" {
  name = "${var.project}-${var.environment}-eks-node-role"

  assume_role_policy = data.aws_iam_policy_document.assume_role_node.json

  tags = merge(
    { Name = "${var.project}_${var.environment}_eks_node_role" },
    var.common_tags
  )
}
resource "aws_iam_role_policy_attachment" "worker_node_role_attachment" {
  count      = length(var.worker_role_policies_arn)
  policy_arn = element(var.worker_role_policies_arn, count.index)
  role       = aws_iam_role.worker_node_role.name
}

