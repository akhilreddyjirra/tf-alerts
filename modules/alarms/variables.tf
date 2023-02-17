variable "lb_name" {
  description = "The ALB's ARN associated with all TGs (need to be the same)"
  default = "test-lb"
}

variable "env" {
  description = "Environment name"
  default = "prod"
}

variable "cluster_id" {
    description = "Kubernates cluster ID"
}

variable "apps" {
  type        = list(string)
  description = "Apps Names"    
  
}
variable "time_response_thresholds" {
  default = {
    period              = "60" //Seconds
    statistic           = "Average"
    threshold           = "30" //Seconds
 }
}

variable "fiveXXs_thresholds" {
  default = {
    period              = "60" //Seconds
    statistic           = "Average"
    threshold           = "1" //Count
 }
}