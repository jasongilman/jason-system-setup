import os
from datetime import datetime
from typing import NotRequired, TypedDict

import boto3
import typer
from mypy_boto3_ec2.type_defs import TagTypeDef

DEVELOPER_NAME = os.getenv("DEVELOPER_NAME") or os.getenv("USER") or "developer"

ec2 = boto3.client("ec2")  # type:ignore
iam = boto3.client("iam")  # type:ignore
ssm = boto3.client("ssm")  # type: ignore

app = typer.Typer(name="instance_launcher")


SECURITY_GROUP_NAME = f"{DEVELOPER_NAME}_egress_only"
ROLE_NAME = f"{DEVELOPER_NAME}_instance"
AMI_SSM_PARAMETER_PREFIX = (
    "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-"
)
DEFAULT_INSTANCE_TYPE = "t4g.medium"


class TaggedItem(TypedDict):
    Tags: NotRequired[list[TagTypeDef]]


def get_tags_dict(item: TaggedItem) -> dict[str, str]:
    return {tag["Key"]: tag["Value"] for tag in item["Tags"]}


def get_name(item: TaggedItem) -> str | None:
    return get_tags_dict(item).get("Name")


def find_vpc() -> str:
    vpcs = ec2.describe_vpcs()["Vpcs"]

    if len(vpcs) > 1:
        raise RuntimeError("More than one VPC found. Please specify a VPC id")
    return vpcs[0]["VpcId"]


def find_private_subnet(vpc_id: str) -> str:
    subnets = ec2.describe_subnets(Filters=[{"Name": "vpc-id", "Values": [vpc_id]}])[
        "Subnets"
    ]
    private_subnets = [
        subnet
        for subnet in subnets
        # Assume that private subnets have private in their name
        if "private" in str(get_name(subnet)).lower()
    ]
    if len(private_subnets) == 0:
        raise RuntimeError("Unable to find a private subnet")
    return private_subnets[0]["SubnetId"]


def find_security_group(vpc_id: str) -> str:
    security_groups = ec2.describe_security_groups(
        Filters=[
            {"Name": "group-name", "Values": [SECURITY_GROUP_NAME]},
            {"Name": "vpc-id", "Values": [vpc_id]},
        ]
    )["SecurityGroups"]

    if len(security_groups) == 0:
        raise RuntimeError(
            (
                f"Unable to find a security group with name {SECURITY_GROUP_NAME}. "
                "Please create it or specify a security group id."
            )
        )
    return security_groups[0]["GroupId"]


def find_iam_role_profile_arn() -> str:
    for page in iam.get_paginator("list_instance_profiles").paginate():
        for profile in page["InstanceProfiles"]:
            if profile["InstanceProfileName"] == ROLE_NAME:
                return profile["Arn"]
    raise RuntimeError(
        (
            f"Unable to find an instance profile with name {ROLE_NAME}. "
            "Please create it or specify a profile arn."
        )
    )


def find_ami(architecture: str = "arm64") -> str:
    return ssm.get_parameter(Name=f"{AMI_SSM_PARAMETER_PREFIX}{architecture}")[
        "Parameter"
    ]["Value"]


def get_ssh_public_key() -> str:
    ssh_key_path = os.path.expanduser("~/.ssh/id_rsa.pub")
    try:
        with open(ssh_key_path, "r") as f:
            return f.read().strip()
    except FileNotFoundError:
        raise RuntimeError(f"SSH public key not found at {ssh_key_path}")


USER_DATA = f"""#cloud-config
packages:
  - git

ssh_authorized_keys:
  - {get_ssh_public_key()}

runcmd:
  - sudo -u ec2-user git clone https://github.com/jasongilman/jason-system-setup.git /home/ec2-user/jason-system-setup
  - sudo -u ec2-user /home/ec2-user/jason-system-setup/bootstrap_instance.sh
"""


@app.command()
def launch_instance(
    vpc_id: str = typer.Option(None, help="VPC ID to launch instance in"),
    subnet_id: str = typer.Option(None, help="Subnet ID to launch instance in"),
    security_group_id: str = typer.Option(
        None, help="Security group ID for the instance"
    ),
    profile_arn: str = typer.Option(None, help="IAM instance profile ARN"),
    ami_id: str = typer.Option(None, help="AMI ID to use for the instance"),
    volume_size: int = typer.Option(100, help="EBS volume size in GB"),
    instance_type: str = typer.Option(DEFAULT_INSTANCE_TYPE, help="EC2 instance type"),
    name: str = typer.Option(None, help="Name tag for the instance"),
) -> None:
    if not vpc_id:
        vpc_id = find_vpc()
    if not subnet_id:
        subnet_id = find_private_subnet(vpc_id)
    if not security_group_id:
        security_group_id = find_security_group(vpc_id)
    if not profile_arn:
        profile_arn = find_iam_role_profile_arn()
    if not ami_id:
        ami_id = find_ami()

    if not name:
        current_time = datetime.now().strftime("%Y-%m-%d %H:%M")
        name = f"{DEVELOPER_NAME} {current_time}"

    instance = ec2.run_instances(
        BlockDeviceMappings=[
            {
                "DeviceName": "/dev/xvda",
                "Ebs": {
                    "DeleteOnTermination": True,
                    "Iops": 3000,
                    "VolumeSize": volume_size,
                    "VolumeType": "gp3",
                    "Throughput": 125,
                    "Encrypted": True,
                },
            }
        ],
        ImageId=ami_id,
        InstanceType=instance_type,  # pyright: ignore[reportArgumentType]
        MaxCount=1,
        MinCount=1,
        SecurityGroupIds=[security_group_id],
        SubnetId=subnet_id,
        UserData=USER_DATA,
        TagSpecifications=[
            {"ResourceType": "instance", "Tags": [{"Key": "Name", "Value": name}]}
        ],
        MetadataOptions={"HttpTokens": "required"},
        IamInstanceProfile={"Arn": profile_arn},
    )["Instances"][0]

    instance_id = instance["InstanceId"]

    print(f"Instance {instance_id} with name {name} launched.")


if __name__ == "__main__":
    app()
