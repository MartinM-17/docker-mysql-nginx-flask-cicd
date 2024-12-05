output "vpc_id" {
  value = aws_vpc.VPC_Ned.id
}

output "subnet_id" {
  value = aws_subnet.Subnet_Ned.id
}

output "security_group_id" {
  value = aws_security_group.SG_Ned.id
}

output "instance_public_ip" {
  value = aws_instance.Web_Ned.public_ip
}

output "instance_id" {
  value = aws_instance.Web_Ned.id
}
