#!/usr/bin/env bash
print_synopsis() {
    echo "Spin up an EC2 instance with an ELB in front of it. Optionally assign it a separate network, or enable auto-scaling."
}

print_usage() {
echo -e "\nUsage: 
  $0 [options]
  $0 [-m {plan|apply}]
  $0 [-v] [-a] [-t]
  $0 [-k <key_id>] [-s <secret_key>]
  $0 [-c <aws credentials file>]
  $0 -h

Options:
  -m, --mode              Mode to ron Terraform on [default: 'plan']
  -v, --vpc               Use a VPC for EC2 and ELB [default: off]
  -a, --autoscale         Enable autoscaling [default: off]
  -c, --credentials-file  File with AWS credentials for dot-sourcing
  -k, --key-id            AWS Access Key ID (read from env by default)
  -s, --secret-key        AWS Secret Access Key (read from env by default)
  -t, --text              Text to show on the index.html [default: 'Cisco SPL']
  -h, --help              Show this message
"
}

TF_VERSION_REQ="0.12"

EXIT_GOOD=0
EXIT_GENERAL=1
EXIT_FILE_NOT_FOUND=2
EXIT_TF_NOT_FOUND=3
EXIT_TF_OUTDATED=4

read_aws_creds_file() {
  if [ ! -f $1 ] ; then
    echo "Error: file $1 doesn't exist"
    exit ${EXIT_FILE_NOT_FOUND}
  fi
  KEY_ID=$(grep "aws_access_key_id=" $1)
  export AWS_ACCESS_KEY_ID=${KEY_ID#*=}
  SECRET_KEY=$(grep "aws_secret_access_key=" $1)
  export AWS_SECRET_ACCESS_KEY=${SECRET_KEY#*=}
}

check_tf_version() {
  if [ $(which terraform >/dev/null 2>&1) ] ; then
    echo "ERROR: Terraform not installed"
    exit ${EXIT_TF_NOT_FOUND}
  fi
  TF_VERSION_INSTALLED=($(terraform --version | head -1 | cut -d'v' -f2 | tr '.' ' '))
  TF_VERSION_INSTALLED="${TF_VERSION_INSTALLED[0]}.${TF_VERSION_INSTALLED[1]}"
  if ! awk 'BEGIN {exit !('${TF_VERSION_INSTALLED}' >= '${TF_VERSION_REQ}')}'; then
    echo "Error: please update to Terraform v${TF_VERSION_REQ} or newer."
  fi
}

while test -n "$1" ; do
  case $1 in
    -h|--help)
      print_synopsis && print_usage
      exit ${EXIT_GOOD}
      ;;
    -m|--mode)
      mode=$2
      shift
      ;;
    -v|--vpc)
      vpc=1
      ;;
    -a|--autoscale)
      scale=1
      ;;
    -c|--credentials-file)
      read_aws_creds_file $2
      shift
      ;;
    -k|--key-id)
      AWS_ACCESS_KEY_ID=$2
      shift
      ;;
    -s|--secret-key)
      AWS_SECRET_ACCESS_KEY=$2
      shift
      ;;
    -t|--text)
      text=$2
      shift
      ;;
    *)
      echo "Error: unknown argument: $1"
      print_usage
      exit ${EXIT_GENERAL}
      ;;
  esac
  shift
done


if [ "${AWS_SECRET_ACCESS_KEY}" == "" -o "${AWS_ACCESS_KEY_ID}" == "" ] ; then
    echo "Error: AWS credentials not specified. Either store them in your environment or submit to the command using '-k' and '-s'."
    print_usage
    exit ${EXIT_GENERAL}
fi

check_tf_version
exit ${EXIT_GENERAL}
