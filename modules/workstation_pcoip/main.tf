#----------------------------------------------------------------
# This module creates all resources necessary for a PCOIP instance in AWS
#----------------------------------------------------------------

variable "houdini_license_server_address" {
}

variable "private_subnets_cidr_blocks" {
  default = []
}

variable "openfirehawkserver" {
}

variable "remote_subnet_cidr" {
}

resource "aws_security_group" "workstation_pcoip" {
  count         = var.site_mounts && var.workstation_enabled ? 1 : 0

  name        = var.name
  vpc_id      = var.vpc_id
  description = "Workstation - Teradici PCOIP security group"

  tags = {
    Name = var.name
  }

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.vpc_cidr]
    description = "all incoming traffic from vpc"
  }

  # todo need to replace this with correct protocols for pcoip instead of all ports.description
  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.remote_ip_cidr]
    description = "all incoming traffic from remote access ip"
  }

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.vpn_cidr]
    description = "all incoming traffic from remote subnet range"
  }

  # For OpenVPN Client Web Server & Admin Web UI

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = [var.remote_ip_cidr]
    description = "ssh"
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [var.remote_ip_cidr, var.remote_subnet_cidr]
    description = "https"
  }
  ingress {
    protocol    = "udp"
    from_port   = 1194
    to_port     = 1194
    cidr_blocks = [var.remote_ip_cidr, var.remote_subnet_cidr]
  }

  ingress {
    protocol    = "udp"
    from_port   = 4172
    to_port     = 4172
    cidr_blocks = [var.remote_ip_cidr, var.remote_subnet_cidr]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 4172
    to_port     = 4172
    cidr_blocks = [var.remote_ip_cidr, var.remote_subnet_cidr]
  }

  ingress {
    protocol    = "icmp"
    from_port   = 8
    to_port     = 0
    cidr_blocks = [var.remote_ip_cidr, var.remote_subnet_cidr]
    description = "icmp"
  }


  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "all outgoing traffic"
  }
}

resource "aws_security_group" "workstation_centos" {
  count         = var.site_mounts && var.workstation_enabled ? 1 : 0

  name        = "gateway_centos"
  vpc_id      = var.vpc_id
  description = "Workstation - Security group"

  tags = {
    Name = "gateway_centos"
  }

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.vpc_cidr]
    description = "all incoming traffic from vpc"
  }

  # todo need to tighten down ports.
  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.remote_ip_cidr]
    description = "all incoming traffic from remote access ip"
  }

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = [var.vpn_cidr]
    description = "all incoming traffic from remote subnet range"
  }

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.houdini_license_server_address}/32"]
    description = "Houdini License Server"
  }

  ingress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["${var.openfirehawkserver}/32"]
    description = "Deadline DB"
  }

  # For OpenVPN Client Web Server & Admin Web UI

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibilty in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    cidr_blocks = concat([var.remote_subnet_cidr, var.remote_ip_cidr], var.private_subnets_cidr_blocks)
    description = "ssh"
  }
  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = [var.remote_ip_cidr]
    description = "https"
  }
  ingress {
    protocol  = "tcp"
    from_port = 27100
    to_port   = 27100
    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibilty in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    cidr_blocks = concat([var.remote_subnet_cidr], var.private_subnets_cidr_blocks)
    description = "DeadlineDB MongoDB"
  }
  ingress {
    protocol  = "tcp"
    from_port = 8080
    to_port   = 8080
    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibilty in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    cidr_blocks = concat([var.remote_subnet_cidr], var.private_subnets_cidr_blocks)
    description = "Deadline And Deadline RCS"
  }
  ingress {
    protocol  = "tcp"
    from_port = 4433
    to_port   = 4433
    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibilty in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    cidr_blocks = concat([var.remote_subnet_cidr], var.private_subnets_cidr_blocks)
    description = "Deadline RCS TLS HTTPS"
  }
  ingress {
    protocol    = "tcp"
    from_port   = 1714
    to_port     = 1714
    cidr_blocks = ["${var.houdini_license_server_address}/32"]
    description = "Houdini license server"
  }
  ingress {
    protocol    = "udp"
    from_port   = 1714
    to_port     = 1714
    cidr_blocks = ["${var.houdini_license_server_address}/32"]
    description = "Houdini license server"
  }
  ingress {
    protocol    = "udp"
    from_port   = 1194
    to_port     = 1194
    cidr_blocks = [var.remote_ip_cidr]
  }
  ingress {
    protocol    = "icmp"
    from_port   = 8
    to_port     = 0
    cidr_blocks = [var.remote_ip_cidr]
    description = "icmp"
  }
  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "all outgoing traffic"
  }
}

variable "provision_softnas_volumes" {
  default = []
}

variable "attach_local_mounts_after_start" {
  default = []
}

# You may wish to use a custom ami of your own creation.  insert the ami details below
variable "use_custom_ami" {
  default = false
}

variable "custom_ami" {
  default = ""
}

locals {
  skip_update = var.skip_update || var.use_custom_ami
}

variable "softnas_private_ip1" {
  default = []
}

# This null resource creates a dependency on the completed volume provisioning from the softnas instance, and the existance of the bastion host.
resource "null_resource" "dependency_softnas_and_bastion" {
  triggers = {
    softnas_private_ip1             = join(",", var.softnas_private_ip1)
    bastion_ip                      = var.bastion_ip
    provision_softnas_volumes       = join(",", var.provision_softnas_volumes)
    attach_local_mounts_after_start = join(",", var.attach_local_mounts_after_start)
  }
}

resource "aws_instance" "workstation_pcoip" {
  #instance type and ami are determined by the gateway type variable for if you want a graphical or non graphical instance.
  depends_on    = [null_resource.dependency_softnas_and_bastion]
  count         = var.site_mounts && var.workstation_enabled ? 1 : 0
  ami           = var.use_custom_ami ? var.custom_ami : var.ami_map[var.gateway_type]
  instance_type = var.instance_type_map[var.gateway_type]

  key_name  = var.key_name
  subnet_id = element(var.private_subnet_ids, count.index)

  vpc_security_group_ids = concat(aws_security_group.workstation_pcoip.*.id, aws_security_group.workstation_centos.*.id)

  ebs_optimized = true
  root_block_device {
    volume_size           = "30"
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name  = "workstation_centos"
    Route = "private"
    Role  = "workstation_centos"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "centos"
      host        = self.private_ip
      private_key = var.private_key
      timeout     = "10m"
    }

    inline = [
      "sleep 60",
    ]
  }
}

variable "public_domain_name" {
}

resource "null_resource" "workstation_pcoip" {
  depends_on = [aws_instance.workstation_pcoip]
  count      = ! local.skip_update && var.site_mounts && var.workstation_enabled ? 1 : 0

  triggers = {
    instanceid = aws_instance.workstation_pcoip[0].id
  }

  provisioner "remote-exec" {
    connection {
      user                = "centos"
      host                = aws_instance.workstation_pcoip[0].private_ip
      bastion_host        = var.bastion_ip
      bastion_user        = "centos"
      private_key         = var.private_key
      bastion_private_key = var.private_key
      type                = "ssh"
      timeout             = "10m"
    }

    # First we install python remotely via the bastion to bootstrap the instance.  We also need this remote-exec to ensure the host is up.
    inline = [
      "sleep 10",
      "set -x",
      "cloud-init status --wait",
      "sudo yum install -y python",
      "while [ ! -f /etc/ssh/ssh_host_ecdsa_key.pub ]",
      "do",
      "  sleep 2",
      "done",
      "cat /etc/ssh/ssh_host_ecdsa_key.pub",
      "cat /etc/ssh/ssh_host_rsa_key.pub",
      "cat /etc/ssh/ssh_host_ecdsa_key.pub",
      "ssh-keyscan ${aws_instance.workstation_pcoip[0].private_ip}",
    ]
  }

  # add ssh keys and initialise users
  # add ssh keys and initialise users
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<EOT
      set -x
      cd /deployuser
      ansible-playbook -i "$TF_VAR_inventory" ansible/ssh-add-private-host.yaml -v --extra-vars "private_ip=${aws_instance.workstation_pcoip[0].private_ip} bastion_ip=${var.bastion_ip}"
      # ansible-playbook -i "$TF_VAR_inventory" ansible/ssh-add-private-host.yaml -v --extra-vars "variable_host=firehawkgateway variable_user=deployuser private_ip=${aws_instance.workstation_pcoip[0].private_ip} bastion_ip=${var.bastion_ip}"
      ansible-playbook -i "$TF_VAR_inventory" ansible/inventory-add.yaml -v --extra-vars "host_name=cloud_workstation1.$TF_VAR_public_domain host_ip=${aws_instance.workstation_pcoip[0].private_ip} group_name=role_workstation_centos insert_ssh_key_string=ansible_ssh_private_key_file=$TF_VAR_local_key_path"

EOT

  }
  provisioner "remote-exec" {
    connection {
      user                = "centos"
      host                = aws_instance.workstation_pcoip[0].private_ip
      bastion_host        = var.bastion_ip
      bastion_user        = "centos"
      private_key         = var.private_key
      bastion_private_key = var.private_key
      type                = "ssh"
      timeout             = "10m"
    }

    # ensure connection is healthy
    inline = [
      "sleep 10",
      "set -x",
      "echo 'remote connection ok'",
    ]
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = <<EOT
      set -x
      cd /deployuser
      ansible-playbook -i "$TF_VAR_inventory" ansible/node-centos-init-users.yaml -v --extra-vars "variable_host=role_workstation_centos hostname=cloud_workstation1.$TF_VAR_public_domain pcoip=true"
      # ansible-playbook -i "$TF_VAR_inventory" ansible/node-centos-init-deadline.yaml -v --extra-vars "variable_host=role_workstation_centos hostname=cloud_workstation1.$TF_VAR_public_domain pcoip=true"
      ansible-playbook -i "$TF_VAR_inventory" ansible/aws-cli-ec2-install.yaml -v --extra-vars "variable_host=role_workstation_centos variable_user=deadlineuser"
      ansible-playbook -i "$TF_VAR_inventory" ansible/aws-cli-ec2-install.yaml -v --extra-vars "variable_host=role_workstation_centos variable_user=centos"
      ansible-playbook -i "$TF_VAR_inventory" ansible/linux-volume-mounts.yaml --extra-vars "variable_host=role_workstation_centos hostname=cloud_workstation1.$TF_VAR_public_domain pcoip=true" --skip-tags "local_install local_install_onsite_mounts" --tags "cloud_install"
      # to configure deadline scripts-
      ansible-playbook -i "$TF_VAR_inventory" ansible/deadline-worker-install.yaml -v --extra-vars "variable_host=role_workstation_centos variable_user=centos variable_connect_as_user=centos"
      # configure houdini and submission scripts
      ansible-playbook -i "$TF_VAR_inventory" ansible/modules/houdini-module/houdini-module.yaml -v --extra-vars "variable_host=role_workstation_centos houdini_build=$TF_VAR_houdini_build firehawk_sync_source=$TF_VAR_firehawk_sync_source" --tags "install_houdini set_hserver install_deadline"
      ansible-playbook -i "$TF_VAR_inventory" ansible/node-centos-ffmpeg.yaml -v --extra-vars "variable_host=role_workstation_centos"
      # to recover from yum update breaking pcoip we reinstall the nvidia driver and dracut to fix pcoip.
      ansible-playbook -i "$TF_VAR_inventory" ansible/node-centos-pcoip-recover.yaml -v --extra-vars "variable_host=role_workstation_centos hostname=cloud_workstation1.$TF_VAR_public_domain pcoip=true"
  
EOT

  }

  #after dracut, we reboot the instance locally.  A reboot command will otherwise cause a terraform error.
  #after dracut, we reboot the instance locally.  A reboot command will otherwise cause a terraform error.
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = var.pcoip_sleep_after_creation ? "aws ec2 stop-instances --instance-ids ${aws_instance.workstation_pcoip[0].id}" : "aws ec2 reboot-instances --instance-ids ${aws_instance.workstation_pcoip[0].id}"
  }
}

resource "null_resource" "shutdown_workstation_pcoip" {
  count = var.sleep && var.site_mounts && var.workstation_enabled ? 1 : 0

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command = "aws ec2 stop-instances --instance-ids ${aws_instance.workstation_pcoip[0].id}"
  }
}

