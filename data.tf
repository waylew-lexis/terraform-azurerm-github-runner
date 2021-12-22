data "template_file" "script" {
  template = file("${path.module}/scripts/startup.sh")
  vars = {
    github_repo   = var.github_repo_name
    github_org    = var.github_org_name
    runner_token  = var.github_runner_token
    runner_name   = local.name
    runner_group  = var.runner_group
    runner_labels = lower(join(",", var.runner_labels))
    runner_scope  = lower(var.runner_scope)
  }
}
