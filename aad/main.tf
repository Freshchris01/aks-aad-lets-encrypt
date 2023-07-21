terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.40.0"
    }
  }
}


# Retrieve domain information
data "azuread_domains" "default" {
  only_initial = true
}

locals {
  domain_name = data.azuread_domains.default.domains.0.domain_name
  users       = csvdecode(file("${path.module}/users.csv"))
}

resource "random_pet" "suffix" {
  length = 2
}

# Create Users
resource "azuread_user" "users" {
  for_each = { for user in local.users : user.first_name => user }

  user_principal_name = format(
    "%s%s-%s@%s",
    substr(lower(each.value.first_name), 0, 1),
    lower(each.value.last_name),
    random_pet.suffix.id,
    local.domain_name
  )

  password = format(
    "%s%s%s!",
    lower(each.value.last_name),
    substr(lower(each.value.first_name), 0, 1),
    length(each.value.first_name)
  )
  force_password_change = true

  display_name = "${each.value.first_name} ${each.value.last_name}"
  department   = each.value.department
  job_title    = each.value.job_title
}

# Create Groups
resource "azuread_group" "devops" {
  display_name = "Devops Team"
  security_enabled = true
}

# Assign group members
resource "azuread_group_member" "education" {
  for_each = azuread_user.users

  group_object_id  = azuread_group.devops.id
  member_object_id = each.value.id
}
