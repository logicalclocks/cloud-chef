import pytest

from procedure import Procedure
from plan import Plan
from executor import Executor

class TestExecutor:

    @pytest.fixture(autouse=True)
    def before_all(self):
        self.proc0_runs = 0
        self.proc1_runs = 0
        self.proc2_runs = 0

        # [
        #   [number of attempts]
        #   [number of success]
        # ]
        self.proc_executions = [[0 for x in range(3)] for y in range(2)]

    # Executor should all the procedures of the plan once
    def test_normal_execution(self):
        
        executor = Executor("Test executor")
        dummy_plan = DummyPlan(self)
        executor.run(dummy_plan)

        # They should have only one attempt
        assert self.proc_executions[0][0] == 1
        assert self.proc_executions[0][1] == 1
        assert self.proc_executions[0][2] == 1

        # And only one successful execution
        assert self.proc_executions[1][0] == 1
        assert self.proc_executions[1][1] == 1
        assert self.proc_executions[1][2] == 1

    # Procedure with `fail_plan` flag should fail the
    # whole plan
    def test_proc_fail_plan(self):
        executor = Executor("Test fail executor")
        fail_plan = FailPlan(self)
        with pytest.raises(Exception):
            executor.run(fail_plan)

        # Second Procedure will fail the entire plan
        # First and second proc should have one attempt each
        assert self.proc_executions[0][0] == 1
        assert self.proc_executions[0][1] == 1
        assert self.proc_executions[0][2] == 0

        # Only the first procedure should have succeeded
        assert self.proc_executions[1][0] == 1
        assert self.proc_executions[1][1] == 0
        assert self.proc_executions[1][2] == 0

    # By default a failed procedure should not fail
    # all the plan
    def test_one_proc_fail(self):
        executor = Executor("Test fail executor")
        plan = FailOneProcPlan(self, 2)
        executor.run(plan)

        # Second procedure will fail for two times
        # but it should not affect the plan
        # Every procedure should have one attempt
        # EXCEPT for two which must have three
        assert self.proc_executions[0][0] == 1
        assert self.proc_executions[0][1] == 3
        assert self.proc_executions[0][2] == 1

        # Since a failed procedure will be retried
        # all of them should eventually succeed
        assert self.proc_executions[1][0] == 1
        assert self.proc_executions[1][1] == 1
        assert self.proc_executions[1][2] == 1

    # Executor should fail the whole plan after
    # maximum number of retries has been reached
    def test_executor_giving_up(self):
        executor = Executor("Test fail executor", 3)
        plan = FailOneProcPlan(self, 100)
        with pytest.raises(Exception):
            executor.run(plan)
        
        # All procedures shoud have run only once
        # EXCEPT for the second which has run until
        # the executor has given up
        assert self.proc_executions[0][0] == 1
        assert self.proc_executions[0][1] == 4
        assert self.proc_executions[0][2] == 1

        # Procedures one and three should have succeed
        assert self.proc_executions[1][0] == 1
        assert self.proc_executions[1][1] == 0
        assert self.proc_executions[1][2] == 1

    # Test execution of a Procedure which returns
    # child procedures
    def test_plan_with_children_procs(self):
        executor = Executor("Test children procs")
        plan = ChildrenPlan(self)
        executor.run(plan)

        assert self.proc_executions[0][0] == 1
        assert self.proc_executions[0][1] == 1
        assert self.proc_executions[0][2] == 1

        assert self.proc_executions[1][0] == 1
        assert self.proc_executions[1][1] == 1
        assert self.proc_executions[1][2] == 1

class DummyPlan(Plan):
    def __init__(self, executor):
        self.executor = executor

    def create(self):
        plan = []
        if self.executor.proc_executions[1][0] == 0:
            proc = DummyProcedure("DummyProc0", self.executor)
            plan.append(proc)

        if self.executor.proc_executions[1][1] == 0:
            proc = DummyProcedure("DummyProc1", self.executor)
            plan.append(proc)

        if self.executor.proc_executions[1][2] == 0:
            proc = DummyProcedure("DummyProc2", self.executor)
            plan.append(proc)
        return plan

class FailPlan(Plan):
    def __init__(self, executor):
        self.executor = executor
    
    def create(self):
        plan = []
        if self.executor.proc_executions[1][0] == 0:
            proc = DummyProcedure("DummyProc0", self.executor)
            plan.append(proc)

        if self.executor.proc_executions[1][1] == 0:
            proc = DummyProcedure("DummyProc1", self.executor, fail=True)
            proc.fail_plan = True
            plan.append(proc)

        if self.executor.proc_executions[1][2] == 0:
            proc = DummyProcedure("DummyProc2", self.executor)
            plan.append(proc)
        return plan

class FailOneProcPlan(Plan):
    def __init__(self, executor, succeed_after):
        self.executor = executor
        self.succeed_after = succeed_after
        self.failures = 0
    
    def create(self):
        plan = []
        if self.executor.proc_executions[1][0] == 0:
            proc = DummyProcedure("DummyProc0", self.executor)
            plan.append(proc)

        if self.executor.proc_executions[1][1] == 0:
            if self.failures < self.succeed_after:
                self.failures += 1
                fail = True
            else:
                fail = False
            proc = DummyProcedure("DummyProc1", self.executor, fail=fail)
            plan.append(proc)

        if self.executor.proc_executions[1][2] == 0:
            proc = DummyProcedure("DummyProc2", self.executor)
            plan.append(proc)
        return plan
    
class ChildrenPlan(Plan):
    def __init__(self, executor):
        self.executor = executor

    def create(self):
        plan = []
        if self.executor.proc_executions[1][0] == 0:
            parent_proc = ParentProcedure("ParentProc", self.executor)
            plan.append(parent_proc)

        return plan

class DummyProcedure(Procedure):

    def __init__(self, name, executor, fail=False):
        self.name = name
        self.executor = executor
        self.fail = fail

    def execute(self):
        if self.name == "DummyProc0":
            self.executor.proc_executions[0][0] += 1
        elif self.name == "DummyProc1":
            self.executor.proc_executions[0][1] += 1
        elif self.name == "DummyProc2":
            self.executor.proc_executions[0][2] += 1

        if self.fail:
            raise Exception("oops")

        if self.name == "DummyProc0":
            self.executor.proc_executions[1][0] += 1
        elif self.name == "DummyProc1":
            self.executor.proc_executions[1][1] += 1
        elif self.name == "DummyProc2":
            self.executor.proc_executions[1][2] += 1

        return []
    
    def rollback(self):
        pass

class ParentProcedure(Procedure):
    def __init__(self, name, executor):
        self.name = name
        self.executor = executor
    
    def execute(self):
        self.executor.proc_executions[0][0] += 1
        self.executor.proc_executions[1][0] += 1
        children = []
        children.append(ChildProcedure("ChildProc0", self.executor))
        children.append(ChildProcedure("ChildProc1", self.executor))
        return children

    def rollback(self):
        pass


class ChildProcedure(Procedure):
    def __init__(self, name, executor):
        self.name = name
        self.executor = executor

    def execute(self):
        if self.name == "ChildProc0":
            self.executor.proc_executions[0][1] += 1
            self.executor.proc_executions[1][1] += 1
        elif self.name == "ChildProc1":
            self.executor.proc_executions[0][2] += 1
            self.executor.proc_executions[1][2] += 1
        return []

    def rollback(self):
        pass