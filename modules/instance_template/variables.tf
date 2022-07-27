variable "account_id" {
  type = string
  description = "service account id"
  default = null
}

variable "serv_display_name" {
  type = string
  description = "service account name"
  default = null
}
  
variable "name" {
  type = string
  description = "name"
  default = null
}
variable "size" {
  type = string
  description = "size"
  default = null
}

variable "type" {
  type = string
  description = "type of disk"
  default = null
}

variable "zone" {
  type = string
  description = "zone for disk"
  default = null
}

variable "snapshot_policy" {
  type        = any
  description = "this is used to hold information on snapshot policy"
  default     =[]
}
variable "instance_template" {
  type        = any
  description = "this is used to create instance template"
  default     =[]
}
