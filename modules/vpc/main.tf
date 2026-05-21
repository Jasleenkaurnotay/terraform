resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Name = "${var.project_name}-vpc"
        Environment = "${var.environment}"
        ManagedBy = "Terraform"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id

    tags = {
        Name = "${var.project_name}-igw"
        Environment = "${var.environment}"
        ManagedBy = "Terraform"
    }
}

# Query number of AZs and dynamically fetch them
data "aws_availability_zones" "azs" {
    state = "available"
}

# Create 2 private subnets for ECS tasks
resource "aws_subnet" "private_subnet" {
    count = 2
    vpc_id = aws_vpc.vpc.id
    availability_zone = data.aws_availability_zones.azs.names[count.index]
    cidr_block = var.private_cidr[count.index]

    tags = {
        Name = "${var.project_name}-private-${count.index + 1}"
        Environment = "${var.environment}"
        ManagedBy = "Terraform"
    }
}

# Create 2 public subnets for ALB
resource "aws_subnet" "public_subnet" {
    count = 2
    vpc_id = aws_vpc.vpc.id
    availability_zone = data.aws_availability_zones.azs.names[count.index]
    cidr_block = var.public_cidr[count.index]

    tags = {
        Name = "${var.project_name}-public-${count.index + 1}"
        Environment = "${var.environment}"
        ManagedBy = "Terraform"
    }
}

# Create 2 RDS subnets for postgres
resource "aws_subnet" "rds_subnet" {
    count = 2
    vpc_id = aws_vpc.vpc.id
    availability_zone = data.aws_availability_zones.azs.names[count.index]
    cidr_block = var.rds_cidr[count.index]

    tags = {
        Name = "${var.project_name}-rds-${count.index + 1}"
        Environment = "${var.environment}"
        ManagedBy = "Terraform"
    }
}

# Create 2 route tables - one private and another public
resource "aws_route_table" "pvt_rt" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"      #All outgoing internet traffic
        nat_gateway_id = aws_nat_gateway.nat_gw.id
    }

    tags = {
        Name = "${var.project_name}-pvt-rt"
        Environment = "${var.environment}"
        ManagedBy = "Terraform"
    }
}

resource "aws_route_table" "pub_rt" {
    vpc_id = aws_vpc.vpc.id
    route {
        cidr_block = "0.0.0.0/0"      #All outgoing internet traffic
        gateway_id = aws_internet_gateway.igw.id
    }
    tags = {
        Name = "${var.project_name}-pub-rt"
        Environment = "${var.environment}"
        ManagedBy = "Terraform"
    }

}

# Associate subnets with route tables, RDS subnets will stay associated with the default route table
resource "aws_route_table_association" "pvt_rt_asst" {
    count = 2
    subnet_id = aws_subnet.private_subnet[count.index].id
    route_table_id = aws_route_table.pvt_rt.id
}

resource "aws_route_table_association" "pub_rt_asst" {
    count = 2
    subnet_id = aws_subnet.public_subnet[count.index].id
    route_table_id = aws_route_table.pub_rt.id
}

# Request public IP for NAT gateway
resource "aws_eip" "nat_eip" {
    domain = "vpc"
    depends_on = [aws_internet_gateway.igw]       # EIP should be allocated after igw exists

    tags = {
        Name = "${var.project_name}-eip"
        Environment = "${var.environment}"
        ManagedBy = "Terraform"
    }
}

# Create NAT gateway and associate with public ip

## NAT gateway itself needs to be able to contact the igw, hence, it also needs internet connectivity

### I am picking one public subnet for the NAT fateway

resource "aws_nat_gateway" "nat_gw" {
    allocation_id = aws_eip.nat_eip.id
    subnet_id = aws_subnet.public_subnet[1].id

    tags = {
        Name = "${var.project_name}-nat-gw"
        Environment = "${var.environment}"
        ManagedBy = "Terraform"
    }
} 