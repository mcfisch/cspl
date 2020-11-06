# CSPL - AWS Challenge for Cisco Application
This project is meant to demonstrate the automated creation of a web server instance in AWS, connected to an Elastic Load Balancer (ELB).

## AWS Components
- Elastic Load Balancer (Classic)
- EC2 instance (Ubuntu)
- Security groups to configure remote access

## Other Components
- Terraform (v0.12) to do the actual setup
- NGINX installed on Ubuntu EC2

## Local Requirements
- Terraform v0.12 or higher
- the following variables need to be set environmentally, optionally submit the path of an AWS CLI credential file to the Bash script
  - AWS_ACCESS_KEY_ID
  - AWS_SECRET_ACCESS_KEY_ID
- execute the following to make sure Terraform has all necessary modules: `terraform init`

## Usage
```
~$ ./cspl.sh --help
Spin up an EC2 instance with an ELB in front of it. Optionally assign it a separate network, enable auto-scaling or specify a different text output.

Usage: 
  ./cspl.sh [options]
  ./cspl.sh [-m {plan|apply|destroy}]
  ./cspl.sh [-v] [-a] [-t]
  ./cspl.sh [-k <key_id>] [-s <secret_key>]
  ./cspl.sh [-c <aws credentials file>]
  ./cspl.sh -h

Options:
  -m, --mode              Mode to run Terraform on [default: 'plan']
  -v, --vpc [CIDR]        Use the give VPC for EC2 and ELB [default: off],
                          'CIDR' defaults to '10.11.12.0/24' when omitted (TBD)
  -a, --autoscale         Enable autoscaling [default: off] (TBD)
  -c, --credentials-file  File with AWS credentials for dot-sourcing
  -k, --key-id            AWS Access Key ID (read from env by default)
  -s, --secret-key        AWS Secret Access Key (read from env by default)
  -t, --text              Text to show on the index.html [default: 'Cisco SPL']
  -h, --help              Show this message
```

## Notes
- The options `--vpc` and `--autoscale` have no affect yet but will be implemented in a future version.
- Due to the current implementation of the argument parsing `--text` can only be a single word. This should be fixed with a future version.