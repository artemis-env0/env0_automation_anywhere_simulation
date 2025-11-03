terraform {
  required_version = ">= 1.4.0"
}

output "hello" {
  value = "From env0 gke Connectivity Test - If you see this that means you're connected to Google Public Cloud and Test was Successful"
}
