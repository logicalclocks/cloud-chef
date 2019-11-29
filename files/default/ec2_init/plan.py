import abc

from typing import Sequence

from procedure import Procedure

class Plan(abc.ABC):
    """
    Plan to be executed by the Executor.
    """

    @abc.abstractmethod
    def create(self) -> Sequence[Procedure]:
        """
        Method to create a Plan. Depending on the current
        state, different Procedures can be executed on
        each run.
        """
        pass
