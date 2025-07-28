from enum import Enum
from typing import Any, Callable

import boto3
import typer
from tabulate import tabulate

ec2 = boto3.client("ec2")  # type:ignore

app = typer.Typer(name="ec2_util")


_STATE_TO_EC2_FN = {
    "start": ec2.start_instances,
    "stop": ec2.stop_instances,
    "terminate": ec2.terminate_instances,
}

_STATE_TO_WAITER_NAME = {
    "start": "instance_running",
    "stop": "instance_stopped",
    "terminate": "instance_terminated",
}


class InstanceState(Enum):
    start = "start"
    stop = "stop"
    terminate = "terminate"

    @property
    def fn(self) -> Callable[..., Any]:
        return _STATE_TO_EC2_FN[self.value]

    @property
    def waiter_name(self) -> str:
        return _STATE_TO_WAITER_NAME[self.value]


@app.command()
def change_instance_state(
    state: InstanceState,
    instance_ids: list[str],
):
    instance_ids = [
        instance_id if instance_id.startswith("i-") else f"i-{instance_id}"
        for instance_id in instance_ids
    ]

    state.fn(InstanceIds=instance_ids)

    print(f"Waiting for instances to {state}")
    waiter = ec2.get_waiter(state.waiter_name)  # type:ignore
    waiter.wait(InstanceIds=instance_ids)  # type:ignore


@app.command()
def list_instances():
    response = ec2.describe_instances()
    instances: list[list[str]] = []
    for reservation in response["Reservations"]:
        for instance in reservation["Instances"]:
            name = ""
            for tag in instance.get("Tags", []):
                if tag["Key"] == "Name":
                    name = tag["Value"]
                    break

            instances.append(
                [
                    instance["InstanceId"],
                    name,
                    instance["State"]["Name"],
                    instance["InstanceType"],
                    instance["LaunchTime"].strftime("%Y-%m-%d %H:%M:%S"),
                ]
            )

    typer.echo(
        tabulate(
            instances, headers=["Instance ID", "Name", "State", "Type", "Launch Time"]
        )
    )


if __name__ == "__main__":
    app()
