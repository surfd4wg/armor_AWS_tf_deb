locals {
    common_tags = {
        Name = "${var.myname}-${random_id.server.hex}" 
	Environment = var.myenv
        Department  = var.mydept
        Organization = var.myorg
        Stack       = var.mystack
        "***RANDOMid***" = "${var.myname}-${random_id.server.id}" 
        "***RANDOMhex***" = "${var.myname}-${random_id.server.hex}" 
        "***RANDOMdec***" = "${var.myname}-${random_id.server.dec}" 
        "***WORKSPACE***" = terraform.workspace
		}
	}
