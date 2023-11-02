terraform {
  required_providers {
    newrelic = {
      source = "newrelic/newrelic"
      version = "3.27.4"   
       }
  }
}

provider "newrelic" {
  # Configuration options
  account_id= 4043696
  api_key="NRAK-S0D6RKUBGBH7CJ6TAT6ALATUCSJ"
}