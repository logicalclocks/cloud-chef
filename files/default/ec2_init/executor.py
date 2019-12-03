import logging
import time

from typing import Sequence

from plan import Plan
from procedure import Procedure

class Executor:
    """
    Main Executor class to execute a Plan.
    The executor will keep running until
    the planner decides that no more Procedures
    need to be executed.
    """
    def __init__(self, name: str, max_retries: int = 5) -> None:
        self.name = name
        self.max_retries = max_retries
        self.retries = 0

    def run(self, plan: Plan) -> None:
        """
        Execute the Plan until there are no more
        Procedures to execute.
        """
        while True:
            procedures = plan.create()
            if len(procedures) == 0:
                logging.info("Executor %s has no more procedures to execute, exiting", self.name)
                break
            self._react(procedures)

            time.sleep(1)


    def _react(self, procedures: Sequence[Procedure]) -> None:
        """
        Actually run the Procedures and their children if any.
        """
        for p in procedures:
            try:
                inner_procedures = p.execute()
                self.retries = 0
                if len(inner_procedures) > 0:
                    self._react(inner_procedures)
            except Exception as ex:
                self.retries += 1
                logging.warning("%s Error executing procedure %s rolling back! Error: %s", self.name, p.name, ex)
                try:
                    p.rollback()
                except Exception as rex:
                    logging.warning("%s Error rolling back %s, continue with next procedure. Error: %s", self.name, p.name, rex)
                if p.fail_plan or self.retries >= self.max_retries:
                    raise ex
        
