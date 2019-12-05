# ECS service role
data "template_file" "ecs_assume_role_policy" {
  template = file("${path.module}/files/ecs_role_assume_policy.tpl.json")
}

# IAM profile for the ECS instance_profile
resource "aws_iam_instance_profile" "ecs_service" {
  name = var.cluster_name
  role = aws_iam_role.ecs_service.name
}

data "template_file" "ec2_assume_policy" {
  template = file("${path.module}/files/ec2_assume_policy.tpl.json")
}

resource "aws_iam_role" "ecs_service" {
  assume_role_policy = data.template_file.ec2_assume_policy.rendered
  name               = var.cluster_name
}

data "template_file" "ecs_elb_service" {
  template = file("${path.module}/files/ecs_elb_policy.tpl.json")
}

resource "aws_iam_policy" "ecs_elb_service" {
  name_prefix = "tf_ecs_elb_policy"
  policy      = data.template_file.ecs_elb_service.rendered
}

resource "aws_iam_policy_attachment" "attach_elb" {
  name       = "ecs_elb_${var.cluster_name}"
  roles      = [aws_iam_role.ecs_service.name]
  policy_arn = aws_iam_policy.ecs_elb_service.arn
}

data "template_file" "instance_profile" {
  template = file("${path.module}/files/instance_profile_policy.tpl.json")
}

resource "aws_iam_role_policy" "instance" {
  name_prefix = "EcsInstanceRole${var.cluster_name}"
  role        = aws_iam_role.ecs_service.name
  policy      = data.template_file.instance_profile.rendered
}

data "template_file" "ecs_policy" {
  template = file("${path.module}/files/ecs_policy.tpl.json")
}

resource "aws_iam_policy" "policy" {
  name_prefix = "ecs_policy"
  policy      = data.template_file.ecs_policy.rendered
}

resource "aws_iam_policy_attachment" "ecs" {
  name       = "ecs_policy"
  roles      = [aws_iam_role.ecs_service.name]
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_policy_attachment" "route" {
  name       = "AmazonRoute53FullAccess"
  roles      = [aws_iam_role.ecs_service.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonRoute53FullAccess"
}

output "ecs_iam_role" {
  value = aws_iam_role.ecs_service.arn
}
