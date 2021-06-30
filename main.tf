terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

provider "github" {}

variable "commit_author" {
  default = "GHA Test"
}

variable "commit_email" {
  default = "seandavidomahoney+gha-test@gmail.com"
}

resource "random_string" "random" {
  length           = 20
  special          = false
}

resource "github_repository" "main" {
  name                  = "${ random_string.random.result }"
  auto_init             = true
}

resource "github_repository_file" "tf" {
  repository          = github_repository.main.name
  file                = "main.tf"
  content             = file("./main.tf")
  commit_message      = "Added Terraform Config"
  commit_author       = "${ var.commit_author }"
  commit_email        = "${ var.commit_email }"
  overwrite_on_create = true
  depends_on = [github_repository.main]
}

resource "github_repository_file" "gha" {
  repository          = github_repository.main.name
  file                = ".github/workflows/index.yaml"
  content             = file("./.github/workflows/index.yaml")
  commit_message      = "Added Github Action"
  commit_author       = "${ var.commit_author }"
  commit_email        = "${ var.commit_email }"
  overwrite_on_create = true
  depends_on = [github_repository.main, github_repository_file.tf]
}