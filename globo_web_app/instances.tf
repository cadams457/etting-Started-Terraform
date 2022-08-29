##################################################################################
# DATA
##################################################################################

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# INSTANCES #
resource "aws_instance" "nginxs" {
  count                  = var.aws_instance_count
  ami                    = nonsensitive(data.aws_ssm_parameter.ami.value)
  instance_type          = var.aws_instance_sizes.small
  subnet_id              = module.vpc.public_subnets[(count.index % var.vpc_subnet_count)].id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
  depends_on             = [aws_iam_role_policy.allow_s3_all]
  #This acutally returns the HTML
  user_data = templatefile("${path.module}/startup_script.tpl", {
    s3_bucket_name = aws_s3_bucket.web_bucket.id
  })

  tags = merge(local.common_tags, {
      Name  = "${local.name_prefix}-nginx-${count.index}"
    })

}