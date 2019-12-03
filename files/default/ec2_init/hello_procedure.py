import logging

from typing import List

from procedure import Procedure

class HelloWorldProcedure(Procedure):
    """
    Example procedure
    """
    def __init__(self, name: str, message: str) -> None:
        self.name = name
        
        self.message = message

    def execute(self) -> List[Procedure]:
        logging.info("%s - Executing: %s", self.name, self.message)
        return []

    def rollback(self) -> None:
        logging.warning("%s - Rolling back", self.name)
