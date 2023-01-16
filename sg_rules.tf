resource "aws_security_group_rule" "allow_db_in" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = "${var.eks_vpc_security_group_id}"
}

resource "aws_security_group_rule" "allow_db_out" {
  type              = "egress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = "${var.eks_vpc_security_group_id}"
}