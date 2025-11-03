MVT - (main.tf)
terraform {
  required_version = ">= 1.4.0"
}
output "hello there, if you see this that means the environment is connected and everything is working as it should" { value = "env0 gke connectivity test" }
