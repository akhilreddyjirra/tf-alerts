data "aws_caller_identity" "current" {}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

data "aws_lb" "main" {
   name = "${var.lb_name}"
}

data "aws_lb_target_group" "main" {
    for_each   = toset(var.apps)    
        name = format("%s-%s-blue",var.cluster_id, each.key)
}

## SNS TOPIC CREATION
resource "aws_sns_topic" "user_updates" {
  name = format("%s-notifications",var.env)
}

# CLOUDWATCH FOR TARGET RESPONCE
resource "aws_cloudwatch_metric_alarm" "target-response-time" {
    for_each   = toset(var.apps)
        alarm_name          = format("%s-Response-Time", each.key)
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods  = "1"
        metric_name         = "TargetResponseTime"
        namespace           = "AWS/ApplicationELB"
        period              = "${lookup(var.time_response_thresholds, "period")}"
        statistic           = "${lookup(var.time_response_thresholds, "statistic")}"
        threshold           = "${lookup(var.time_response_thresholds, "threshold")}"

        dimensions = {
            LoadBalancer = data.aws_lb.main.arn_suffix
            TargetGroup  = data.aws_lb_target_group.main[each.key].arn_suffix
        }

        alarm_description   = format("Trigger an alert when response time in %s goes high", data.aws_lb_target_group.main[each.key].name)
        alarm_actions       = [aws_sns_topic.user_updates.arn]
        ok_actions          = [aws_sns_topic.user_updates.arn]
        treat_missing_data  = "notBreaching"
        datapoints_to_alarm = "5"
}

# CLOUDWATCH FOR HEALTHY CONUNT
resource "aws_cloudwatch_metric_alarm" "target-healthy-count" {
    for_each   = toset(var.apps)
        alarm_name          = format("%s-Healthy-Count", each.key)
        comparison_operator = "LessThanOrEqualToThreshold"
        evaluation_periods  = "1"
        metric_name         = "HealthyHostCount"
        namespace           = "AWS/ApplicationELB"
        period              = "60"
        statistic           = "Average"
        threshold           = "0"

        dimensions = {
            LoadBalancer = data.aws_lb.main.arn_suffix
            TargetGroup  = data.aws_lb_target_group.main[each.key].arn_suffix
        }

        alarm_description   = format("Trigger an alert when %s has 1 or more unhealthy hosts", data.aws_lb_target_group.main[each.key].name)
        alarm_actions       = [aws_sns_topic.user_updates.arn]
        ok_actions          = [aws_sns_topic.user_updates.arn]
        treat_missing_data  = "breaching"
        datapoints_to_alarm = "5"
}

# CLOUDWATCH FOR TARGET 5XX
resource "aws_cloudwatch_metric_alarm" "target-500" {
    for_each   = toset(var.apps)
        alarm_name          = format("%s-HTTP-5XX", each.key)
        comparison_operator = "GreaterThanOrEqualToThreshold"
        evaluation_periods  = "1"
        metric_name         = "HTTPCode_Target_5XX_Count"
        namespace           = "AWS/ApplicationELB"
        period              = "${lookup(var.fiveXXs_thresholds, "period")}"
        statistic           = "${lookup(var.fiveXXs_thresholds, "statistic")}"
        threshold           = "${lookup(var.fiveXXs_thresholds, "threshold")}"

        dimensions = {
            LoadBalancer = data.aws_lb.main.arn_suffix
            TargetGroup  = data.aws_lb_target_group.main[each.key].arn_suffix
        }

        alarm_description   = format("Trigger an alert when 5XX's in %s goes high", data.aws_lb_target_group.main[each.key].name)
        alarm_actions       = [aws_sns_topic.user_updates.arn]
        ok_actions          = [aws_sns_topic.user_updates.arn]
        treat_missing_data  = "notBreaching"
        datapoints_to_alarm = "5"
}