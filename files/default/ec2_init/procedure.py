import abc

from typing import List

class Procedure(abc.ABC):
    """
    Basic unit of work to be executed by the Executor.
    It may return a list of other Procedures
    """

    @abc.abstractmethod
    def execute(self) -> List['Procedure']:
        pass

    @abc.abstractmethod
    def rollback(self) -> None:
        pass

    @property
    def fail_plan(self) -> bool:
        if hasattr(self, "_fail_plan"):
            return self._fail_plan
        return False
    
    @fail_plan.setter
    def fail_plan(self, fail: bool) -> None:
        self._fail_plan = fail

    @property
    def name(self) -> str:
        if hasattr(self, "_name"):
            return self._name
        return "Unknown procedure"

    @name.setter
    def name(self, name: str) -> None:
        self._name = name