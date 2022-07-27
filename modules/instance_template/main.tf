resource "google_service_account" "service_account" {
  account_id   = var.account_id
  display_name = var.serv_display_name
}

locals {
  snapshot_policy = [
    for policy in var.snapshot_policy : {
      name                       = policy.name
      region                     = policy.region
      snapshot_schedule_policy   = policy.snapshot_schedule_policy
      
    }
  ]
  instance_template = [
   for template in var.instance_template : {
      name                       = template.name
      description                = template.description
      tags                       = template.tags
      instance_description       = template.instance_description 
      machine_type               = template.machine_type
      can_ip_forward             = template/can_ip_forward

    }
  
  ]
}

resource "google_compute_instance_template" "instance_template" {
  for_each     = { for template in var.instance_template : lower(template.name) => template }
  name                 = each.value.name
  description          = each.value.description
  tags                 = each.value.tags
  instance_description = each.value.template.instance_description
  machine_type         = each.value.machine_type
  can_ip_forward       = each.value.can_ip_forward

  dynamic labels {
    for_each = lookup(each.value, "labels", null) == null ? [] : [each.value.labels]
    content {
      environment = labels.value.environment
    }
  }

  dynamic scheduling {
    for_each = lookup(each.value, "scheduling", null) == null ? [] : [each.value.scheduling]
    content {
    automatic_restart   = lookup(each.value.scheduling.automatic_restart)
    on_host_maintenance = lookup(each.value.scheduling.on_host_maintenance)
  }
  }

  dynamic disk {
    for_each = lookup(each.value, "disk", null) == null ? [] : [each.value.disk]
    content {
    source_image      = lookup(each.value.disk.source_image)
    auto_delete       = lookup(each.value.disk.auto_delete)
    boot              = lookup(each.value.disk.boot)
    resource_policies = [google_compute_resource_policy.compute_disk.id]
  }
  }

  dynamic network_interface {
    for_each = lookup(each.value, "network_interface", null) == null ? [] : [each.value.network_interface]
    content {
    network = network_interface.value.network
  }
  }

  dynamic metadata_startup_script {
    for_each = lookup(each.value, "metadata_startup_script", null) == null ? [] : [each.value.metadata_startup_script]
    content {
    metadata_startup_script = metadata_startup_script.value.metadata_startup_script
  }
  }

  dynamic service_account {
    for_each = lookup(each.value, "service_account", null) == null ? [] : [each.value.service_account]
    content {
    email  = lookup(each.value.service_account.email)
    scopes = lookup(each.value.service_account.scopes)
  }
}
}

data "google_compute_image" "my_image" {
  family  = "linux"
  project = "xyz"
}

resource "google_compute_disk" "compute_disk" {
  name  = var.name
  image = data.google_compute_image.my_image.self_link
  size  = var.size
  type  = var.type
  zone  = var.zone
}

resource "google_compute_resource_policy" "snapshot_policy" {
  for_each     = { for policy in var.snapshot_policy : lower(policy.name) => policy }
  name   = each.value.name
  region = each.value.region
  snapshot_schedule_policy {
    for_each = lookup(each.value.snapshot_schedule_policy, "schedule", null) == null ? [] : [each.value.snapshot_schedule_policy.schedule]
    dynamic schedule {
              daily_schedule {
        days_in_cycle =lookup(schedule.value,"days_in_cycle",null)
        start_time    = lookup(schedule.value,"start_time",null)
      }
    }
  }
}

