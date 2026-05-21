output "vpc_id" {
    value = aws_vpc.vpc.id
}

output "igw_id" {
    value = aws_internet_gateway.igw.id
}

output "private_subnet" {
    value = aws_subnet.private_subnet[*].id   #[*] = all elements
}

output "public_subnet" {
    value = aws_subnet.public_subnet[*].id
}

output "rds_subnet" {
    value = aws_subnet.rds_subnet[*].id
}

output "pvt_rt" {
    value = aws_route_table.pvt_rt.id
}

output "pub_rt" {
    value = aws_route_table.pub_rt.id
}

output "pvt_rt_asst" {
    value = aws_route_table_association.pvt_rt_asst[*].id
}

output "pub_rt_asst" {
    value = aws_route_table_association.pub_rt_asst[*].id
}

output "nat_gw_id" {
    value = aws_nat_gateway.nat_gw.id
}

output "nat_gw_eip" {
    value = aws_nat_gateway.nat_gw.public_ip
}