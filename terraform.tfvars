service_account = [
    {
        account_id = "109811476087443950171"
        display_name ="service account"
    }
]

        name  = "disk"
        size  = 10
        type  = "pd-ssd"
        zone  = "us-central1"

instance_template = [

 {
  template_name                = "instance-template_test"
  instance_description         =  "This template is used to create vm instances."
  tags                         = ["project_id"]
  instance_description         = "description assigned to instances"
  machine_type                 = "e2-medium"
  can_ip_forward               = false

  labels = {
    environment = "dev"
  }

  scheduling ={
    automatic_restart   = true
    on_host_maintenance = "MIGRATE"
  }

  disk= {
    source_image      = "c1-deeplearning-tf-1-15-cu110-v20220701-debian-10"
    auto_delete       = true
    boot              = true
  }

  network_interface = {
    network = "default"
  }

  metadata_startup_script ={

    metadata_startup_script = file("./modules/startup.sh")
  }

  service_account = {
   
    email  = "870933977059-compute@developer.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }
}
]

snapshot_policy = [
    {
    name   = "policy"
    region = "us-central1"
      snapshot_schedule_policy= {
        schedule = {
          daily_schedule = {
             days_in_cycle = 1
             start_time    = "5:00"
      }
    }
      }
    }  
]
 
