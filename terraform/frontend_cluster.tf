# Deploy 3 Ubuntu VMs with No External IP
resource "aws_instance" "frontend_vm" {
  depends_on = [
    aws_nat_gateway.nat,
    aws_internet_gateway.igw,
    aws_route_table_association.private_frontend
  ]
  
  count                  = 3
  # Set Latest Ubuntu 22.04 AMI
  # ami                    = data.aws_ami.ubuntu_image.id
  # Set Specific AMI Image 
  ami                    = var.ec2_setting_values["ami"]
  instance_type          = var.ec2_setting_values["instance_type"]
  subnet_id              = aws_subnet.private_frontend.id
  vpc_security_group_ids = [aws_security_group.private_frontend_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  source_dest_check      = false

  # Assign Private IP Address
  private_ip = var.kubernetes_private_frontend_ips[count.index]

  # Configure the root storage drive to 60 GB
  root_block_device {
    volume_size           = 60
    volume_type           = "gp3"
    delete_on_termination = true
  }

  # This explicitly prevents assigning a public/external IP address
  associate_public_ip_address = false

  # Use the kube_install script to configure the instance on boot
  user_data                   = file("${path.module}/user_data/kube_install.sh")
  user_data_replace_on_change = true

  tags = {
    Name = count.index == 0 ? "frontend-control-plane-${count.index + 1}" : "frontend-worker-node-${count.index}"
    Role = count.index == 0 ? "Control_Plane_${count.index + 1}" : "Worker_Node_${count.index}"
  }
}