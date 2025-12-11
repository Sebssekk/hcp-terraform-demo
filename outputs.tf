output "Instance_Public_IP" {
  value = aws_instance.tf_instance.public_ip
  description = "The Public IP of the demo instance"
}