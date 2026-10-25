
# ----------------------------------------
# Environment configuration using workspaces
# ----------------------------------------

locals {
  environments = {
    dev = {
      vpc_cidr         = "10.10.0.0/16"
      public_subnet_1  = "10.10.1.0/24"
      public_subnet_2  = "10.10.2.0/24"
      private_subnet_1 = "10.10.3.0/24"
      private_subnet_2 = "10.10.4.0/24"
    }

    qa = {
      vpc_cidr         = "10.20.0.0/16"
      public_subnet_1  = "10.20.1.0/24"
      public_subnet_2  = "10.20.2.0/24"
      private_subnet_1 = "10.20.3.0/24"
      private_subnet_2 = "10.20.4.0/24"
    }

    uat = {
      vpc_cidr         = "10.30.0.0/16"
      public_subnet_1  = "10.30.1.0/24"
      public_subnet_2  = "10.30.2.0/24"
      private_subnet_1 = "10.30.3.0/24"
      private_subnet_2 = "10.30.4.0/24"
    }

    prod = {
      vpc_cidr         = "10.40.0.0/16"
      public_subnet_1  = "10.40.1.0/24"
      public_subnet_2  = "10.40.2.0/24"
      private_subnet_1 = "10.40.3.0/24"
      private_subnet_2 = "10.40.4.0/24"
    }
  }

  # Select CIDRs based on the active workspace.
  # The dev fallback allows Terraform to evaluate the
  # configuration, but the precondition below prevents
  # deployment from an unsupported workspace.
  env = lookup(
    local.environments,
    terraform.workspace,
    local.environments["dev"]
  )
}

# ----------------------------------------
# 1. VPC
# ----------------------------------------

resource "aws_vpc" "main" {
  cidr_block           = local.env.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${terraform.workspace}-vpc"
    Environment = terraform.workspace
  }

  lifecycle {
    precondition {
      condition = contains(
        keys(local.environments),
        terraform.workspace
      )
      error_message = "Unsupported workspace. Use dev, qa, uat, or prod."
    }
  }
}

# ----------------------------------------
# 2. Public Subnet 1
# ----------------------------------------

resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.env.public_subnet_1
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${terraform.workspace}-public-subnet-1"
    Environment = terraform.workspace
    Type        = "Public"
  }
}

# ----------------------------------------
# 3. Public Subnet 2
# ----------------------------------------

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = local.env.public_subnet_2
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "${terraform.workspace}-public-subnet-2"
    Environment = terraform.workspace
    Type        = "Public"
  }
}

# ----------------------------------------
# 4. Private Subnet 1
# ----------------------------------------

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.env.private_subnet_1
  availability_zone = "ap-south-1a"

  tags = {
    Name        = "${terraform.workspace}-private-subnet-1"
    Environment = terraform.workspace
    Type        = "Private"
  }
}

# ----------------------------------------
# 5. Private Subnet 2
# ----------------------------------------

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = local.env.private_subnet_2
  availability_zone = "ap-south-1b"

  tags = {
    Name        = "${terraform.workspace}-private-subnet-2"
    Environment = terraform.workspace
    Type        = "Private"
  }
}

# ----------------------------------------
# 6. Internet Gateway
# ----------------------------------------

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${terraform.workspace}-igw"
    Environment = terraform.workspace
  }
}

# ----------------------------------------
# 7. Public Route Table
# ----------------------------------------

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${terraform.workspace}-public-rt"
    Environment = terraform.workspace
  }
}

# ----------------------------------------
# 8. Public Route Table Associations
# ----------------------------------------

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

# ----------------------------------------
# 9. Private Route Table
# ----------------------------------------

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${terraform.workspace}-private-rt"
    Environment = terraform.workspace
  }
}

# ----------------------------------------
# 10. Private Route Table Associations
# ----------------------------------------

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}


