# Declare the hcloud_token variable from .tfvars
variable "hcloud_token" {
  sensitive = true # Requires terraform >= 0.14
}
variable "master_node_count" {
  type = number
  default = 3
}

variable "etcd_node_count" {
  type = number
  default = 3
}
variable "worker_node_count" {
  type = number
  default = 3
}

variable "location" {
  type = string
  default = "fsn1"
  
}