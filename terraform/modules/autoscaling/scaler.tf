// Autoscaling policies
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

// Autoscaling policies
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.asg.name
}

// Alarms
// Scale up
resource "aws_cloudwatch_metric_alarm" "scale_up" {
  alarm_name          = "scale-up-${var.cluster_name}"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"
  period              = "300"
  statistic           = "Average"
  threshold           = "30"

  dimensions = {
    ClusterName = var.cluster_name
  }

  alarm_description = "When triggered it will scale the cluster"
  alarm_actions     = [aws_autoscaling_policy.scale_up.arn]
}

// Scale down
resource "aws_cloudwatch_metric_alarm" "scale_down" {
  alarm_name          = "scale-down-${var.cluster_name}"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryReservation"
  namespace           = "AWS/ECS"

  period    = "900"
  statistic = "Average"
  threshold = "5"

  dimensions = {
    ClusterName = var.cluster_name
  }

  alarm_description = "When triggered it will scale down the cluster"
  alarm_actions     = [aws_autoscaling_policy.scale_down.arn]
}

