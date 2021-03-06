# CSPL - AWS Challenge for Cisco Application

## General Schema
![CSPL General Schema](cspl_schema.png)

## AWS Components
- Elastic Load Balancer (Classic ~~or Application?~~) (done)
- EC2 instance (Ubuntu) (done)
- Security group to configure remote access ~~?~~ (done)

### In EC2 Ubuntu
- NGINX inside EC2 Ubuntu (done)
- HTML file (echo'ing out after nginx install doesn't work, breaks nginx install: --> will implement seperate copy of prebuilt file instead)

#### Additional Options
- Autoscaling Group
- VPC definition
- S3 Bucket to store status?

### Locally
- BASH script to control overall process
- Terraform to manage installation/maintenance (in progress)
- ~~AWS-CLI for direct communication with AWS API~~ (not necessary as TF has its own modules for this)

## Encountered Issues I need to solve
- ~~`terraform apply` fails when trying to install NGINX and echo'ing out the html file is enabled~~ fixed
- Generating dynamic SSH key doesn't work yet, but static keys do work

## Open Questions / Topics to Check 
- ~~Which ELB service to use, classic or application? (need to read)~~ classic ELB
- ~~Is a security group necessary when using ELB? (reading as well)~~ yes, sec. groups necessary and implemented
- DNS (probably unneeded here)

## Script: Tasks to Cover
- ~~Check if service is already existing, verify status~~ obsolete
- Create/update/destroy ELB (done)
- Create/update/destroy EC2 instance (done) 
- If necessary update S3 with status (not yet implemented)
- setup VPC if resp. parameter is set (not yet implemented)
- configure Autoscaling if resp. parameter is set (not yet implemented)
