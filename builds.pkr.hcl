packer {
  required_plugins {
    azure = {
      version = "~> 2"
      source  = "github.com/hashicorp/azure"
    }
  }
}
build {
  sources = ["source.azure-arm.isucon"]
  provisioner "shell" {
    inline = ["/usr/bin/cloud-init status --wait"]
  }

  provisioner "shell" {
    script = "provision.sh"
  }
}
