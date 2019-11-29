#!/usr/bin/env python
import logging
import argparse

from executor import Executor
from hello_plan import HelloWorldPlan

def _setup_logging() -> None:
    logging.basicConfig(format="%(asctime)s %(levelname)s [%(module)s/%(funcName)s] %(message)s", level=logging.DEBUG)

def _parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Init Hopsworks cloud instance")
    parser.add_argument("--gateway", "-g", required=True, help="Hopsworks Cloud API gateway")
    parser.add_argument("--user-id", "-u", required=True, help="User identifier")
    return parser.parse_args()

if __name__ == '__main__':
    args = _parse_arguments()
    _setup_logging()
    logging.info("Starting EC2 init")
    logging.debug("Creating executor")

    logging.debug("Hopsworks API gateway: %s", args.gateway)
    logging.debug("User ID: %s", args.user_id)

    executor = Executor("Init executor")
    logging.debug("Creating hello world plan")
    hello_plan = HelloWorldPlan("Hello world plan")
    logging.debug("Executing Hello world plan")
    executor.run(hello_plan)