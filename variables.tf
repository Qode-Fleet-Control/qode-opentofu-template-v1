variable "project" {
  description = "Short project name, used as the prefix of every generated name."
  type        = string
  default     = "fleet"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,20}$", var.project))
    error_message = "project must be 2-21 chars of lowercase letters, digits and dashes, starting with a letter."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of dev, staging, prod."
  }
}

variable "pet_length" {
  description = "Number of words in the generated pet name."
  type        = number
  default     = 2
}
