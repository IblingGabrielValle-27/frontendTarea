variable "tenancy_ocid" {
  description = "The OCID of the tenancy."
  type        = string
}
variable "user_ocid" {
  description = "The OCID of the user."
  type        = string
}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}
variable "compartment_ocid" {}
variable "subnet_id" {}
variable "availability_domain" {}
variable "ubuntu_2204_image_ocid" {
  description = "The OCID of the Ubuntu 22.04 image."
}
variable "ssh_public_key" {
  description = "The SSH public key for accessing the instance."
}
