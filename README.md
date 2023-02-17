Terraform module for AWS Target Group Alarms 
========================

Terraform module which add CloudWatch alarms for Target Group associated services.

An alarm will be triggered if:

* No healthy ec2 are registered with the Target Group.
* if response code 5XX coming from the TG are greater than or equal to the configured threshold.
* if response time value is greater than the configured threshold.

> Note: Thresholds other than defaults can be overwriten passing variables as shown below.


Usage
-----

```hcl
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
```

