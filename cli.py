from __future__ import annotations

import subprocess
import sys
from configparser import ConfigParser
from enum import Enum
from typing import Any, List, Optional

import click


class Services(str, Enum):
    AUTH = "auth"
    BALANCE = "balance"
    BOT = "bot"
    LIKE = "like"


class CLIConfigParser(ConfigParser):
    def __init__(self, name: str, *args: Any, **kwargs: Any) -> None:
        super(CLIConfigParser, self).__init__(
            *args, **kwargs, converters={"list": lambda x: [i.strip() for i in x.split(",")]}
        )

        self.read(name)


class Config:
    def __init__(
        self,
        docker: str,
        command: str,
        service: Optional[Services],
        compose: Optional[List[str]],
        captures: Optional[List[str]],
        config_file: str,
        env_file: str,
    ) -> None:
        self.docker = docker
        self.command = command
        self.service = service
        self.compose = compose
        self.captures = captures
        self.config_file = config_file
        self.env_file = env_file

    def start_web(self) -> List[str]:
        command = [self.docker]

        config = CLIConfigParser(self.config_file)

        for service in Services:  # type: Services
            command.append("-f")
            command.append(" -f ".join(config.getlist(f"docker.{service.value}", "run")))
            command.append(f"-f {config[f'docker.{service.value}']['networks']}")

        command.append("-f")
        command.append("-f ".join(config.getlist("docker", "run")))
        command.append(f"--env-file {self.env_file}")
        command.append(self.command)

        return command

    def start_service(self) -> List[str]:
        if not self.compose:
            raise RuntimeError("Provide at least one compose file!")

        command = [self.docker]

        config = CLIConfigParser(self.config_file)

        command.append("-f")
        command.append(
            " -f ".join(
                f"{config[f'docker.{self.service.value}']['location']}/{compose}.yml"
                for compose in self.compose
            )
        )
        command.append(f"-f {config[f'docker.{self.service.value}']['networks']}")
        command.append(f"--env-file {self.env_file}")
        command.append(self.command)

        if self.captures:
            command.append(f"--abort-on-container-exit --exit-code-from {' '.join(self.captures)}")

        return command

    def start(self) -> None:
        command = self.start_web()
        if self.service:
            command = self.start_service()

        print(command)

        with subprocess.Popen(
            " ".join(command), shell=True, stdin=sys.stdin, stdout=sys.stdout, stderr=sys.stderr
        ) as process:
            process.wait()


@click.command()
@click.option(
    "--docker",
    type=click.Choice(["docker-compose", "docker compose"]),
    show_default=True,
    default="docker compose",
    help="Currently 2 versions are supported " "please pass the version you will use",
)
@click.option(
    "--command", type=str, help="Command to be passed to Docker: docker compose $COMMAND"
)
@click.option(
    "--service",
    type=Services,
    default=None,
    help="Service that will be launched",
)
@click.option(
    "--compose",
    multiple=True,
    default=None,
    help="Composes in the service that will be launched",
)
@click.option(
    "--captures",
    multiple=True,
    default=None,
    help="Similar to Docker abort on container exit pass service names",
)
@click.option(
    "--config-file",
    "config_file",
    default="config.ini",
    help="Config file",
)
@click.option(
    "--env-file",
    "env_file",
    default=".env",
    help="Env file",
)
def main(
    docker: str,
    command: str,
    service: Optional[Services],
    compose: Optional[List[str]],
    captures: Optional[List[str]],
    config_file: str,
    env_file: str,
) -> None:
    """
    Python script for launching Docker images and
    collecting microservices into one service with nginx
    """

    run(
        docker=docker,
        command=command,
        service=service,
        compose=compose,
        captures=captures,
        config_file=config_file,
        env_file=env_file,
    )


def run(
    docker: str,
    command: str,
    service: Optional[Services],
    compose: Optional[List[str]],
    captures: Optional[List[str]],
    config_file: str,
    env_file: str,
) -> None:
    config = Config(
        docker=docker,
        command=command,
        service=service,
        compose=compose,
        captures=captures,
        config_file=config_file,
        env_file=env_file,
    )
    config.start()


if __name__ == "__main__":
    main()
