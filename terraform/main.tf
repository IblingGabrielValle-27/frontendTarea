data "template_file" "cloud_init_script"{
  template = file("${path.module}/cloud_init.sh")
}

resource "oci_core_instance" "Ubuntu_vm" {
  availability_domain = var.availability_domain
  shape               = "VM.Standard.E2.1.Micro"
  compartment_id      = var.compartment_ocid
  display_name        = "ubuntu-docker-vm"

  source_details {
    source_type = "image"
    source_id   = var.ubuntu_2204_image_ocid
  }

  create_vnic_details {
    subnet_id        = var.subnet_id
    assign_public_ip = true
    display_name     = "ubuntu-docker-vm-vnic"
    hostname_label   = "ubuntu-docker-vm"
  }


    metadata = {
      ssh_authorized_keys = var.ssh_public_key
      user_data = base64encode(data.template_file.cloud_init_script.rendered)
    }
}

output "public_ip" {
  value       = oci_core_instance.Ubuntu_vm.public_ip
}

