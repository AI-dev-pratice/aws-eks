data "aws_availability_zones" "available_zone" {
    state = "available"
}
data "aws_iam_policy_document" "assume_role_node" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}