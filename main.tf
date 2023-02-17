module "alarms" {
  source          = "./modules/alarms"
  env             = "prod"
  cluster_id      = "prod"
  apps            = ["cat", "dog"]

  time_response_thresholds = { 
    period = "60" 
    statistic = "Average" 
    threshold = "30" 
  } 
  fiveXXs_thresholds = {
    period = "60"
    statistic = "Average"
    threshold = "1"
  }
}

