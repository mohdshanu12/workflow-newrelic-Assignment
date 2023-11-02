// Create a policy to track
resource "newrelic_alert_policy" "my-policy" {
  name = "Nov-policy"
}


# data "newrelic_entity" "app" {
#   name = "my-app"
#   type = "APPLICATION"
#   domain = "APM"
# }

resource "newrelic_nrql_alert_condition" "foo" {
  account_id                     = 4043696
  policy_id                      = newrelic_alert_policy.my-policy.id
  type                           = "static"
  name                           = "foo"
  description                    = "Alert when transactions are taking too long"
  runbook_url                    = "https://www.example.com"
  enabled                        = true
  violation_time_limit_seconds   = 3600
  fill_option                    = "static"
  fill_value                     = 1.0
  aggregation_window             = 60
  aggregation_method             = "event_flow"
  aggregation_delay              = 120
  expiration_duration            = 120
  open_violation_on_expiration   = true
  close_violations_on_expiration = true
  slide_by                       = 30

  nrql {
    query = "SELECT average(host.cpuPercent) AS 'CPU used %' FROM Metric WHERE `entityGuid` = 'NDA0MzY5NnxJTkZSQXxOQXw4MTAzODA1NTgxNDQ4OTYxMTM2'"
  }

  critical {
    operator              = "above"
    threshold             = 5.5
    threshold_duration    = 300
    threshold_occurrences = "ALL"
  }

  warning {
    operator              = "above"
    threshold             = 3.5
    threshold_duration    = 600
    threshold_occurrences = "ALL"
  }
}

// Create a reusable email notification destination
resource "newrelic_notification_destination" "email-destination" {
  name = "destination-email"
  type = "EMAIL"

  property {
    key = "email"
    value = "shanumohd524@gmail.com" // Replace with the email address you want to send notifications to
  }
}

// Create an email notification channel to use in the workflow
resource "newrelic_notification_channel" "email-channel" {
  name = "Notification-channel-email"
  type = "EMAIL"
  destination_id = newrelic_notification_destination.email-destination.id

  product = "IINT" // Please note the product used!
 
 
  property {
    key = "payload"
    value = "{}"
    label = "Payload Template"
  }
}

// A workflow that matches issues that include incidents triggered by the policy

resource "newrelic_workflow" "foo" {
  name = "Workflow-Nov"
  muting_rules_handling = "NOTIFY_ALL_ISSUES"

  issues_filter {
    name = "Filter-name"
    type = "FILTER"

    predicate {
      attribute = "labels.policyIds"
      operator = "EXACTLY_MATCHES"
      values = [newrelic_alert_policy.my-policy.id]
    }
  }

  destination {
    channel_id = newrelic_notification_channel.email-channel.id
  }
}
