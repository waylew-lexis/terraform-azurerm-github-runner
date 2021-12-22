variable "runner_token" {
  description = "github runner token"
  type        = string
  sensitive   = true
}

variable "repo_name" {
  description = "the name of the rba repository the runner will be associated to"
  type        = string
}