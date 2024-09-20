module "sandbox" {
  source = "./modules/aft-account-request"

  control_tower_parameters = {
    AccountEmail              = "alex.vartoumian+devRole2@gmail.com"
    AccountName               = "development_account2"
    ManagedOrganizationalUnit = "production (ou-aklj-5ybhenyi)" #target specific OU based on service catalog template
    SSOUserEmail              = "alex.vartoumian+devRole2@gmail.com"
    SSOUserFirstName          = "devrole2"
    SSOUserLastName           = "devrole2"
  }

  account_tags = {
    "Learn Tutorial" = "AFT1"
  }

  change_management_parameters = {
    change_requested_by = "HashiCorp Learn"
    change_reason       = "Learn AWS Control Tower Account Factory for Terraform"
  }

  custom_fields = {
    group = "non-prod"
     alternate_contact = jsonencode(
      {
        "billing"= {
          "email-address" = "billing@mycompany.com",
          "name"          = "Account Receiveable",
          "phone-number"  = "+11234567890",
          "title"         = "silly Billy Department"
        },
        "operations"= {
          "email-address" = "ops@mycompany.com",
          "name"          = "Operations 24/7",
          "phone-number"  = "+11234567890",
          "title"         = "DevOps Team"
        },
        "security"= {
          "email-address" = "soc@mycompany.com",
          "name"          = "Security Ops Center",
          "phone-number"  = "+11234567890",
          "title"         = "SOC Team"
        }
      }
    )
  }

  account_customizations_name = "sandbox"
}
