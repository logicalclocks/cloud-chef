import logging

from typing import Sequence

from plan import Plan
from hello_procedure import HelloWorldProcedure
from procedure import Procedure

class HelloWorldPlan(Plan):
    """
    Example plan
    """
    def __init__(self, name: str) -> None:
        self.name = name
        self.counter = 0

    def create(self) -> Sequence[Procedure]:
        plan = []
        if self.counter < 2:
            proc0 = HelloWorldProcedure("proc0", "executing proc0")
            plan.append(proc0)
            logging.debug("%s - Added proc0", self.name)

            proc1 = HelloWorldProcedure("proc1", "executing proc1")
            plan.append(proc1)
            logging.debug("%s - Added proc1", self.name)

            if self.counter < 1:
                proc2 = HelloWorldProcedure("proc2", "executing proc2")
                plan.append(proc2)
                logging.debug("%s - Added proc2", self.name)

            self.counter = self.counter + 1

        return plan
