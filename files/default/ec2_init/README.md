# EC2 init executor

Python script to perform some setup operations on a newly spawn EC2 instance

## Running

    conda create -n airflow_env python=3
    pip install mypy

    python ec2_init.py

## Development

A **Procedure** is the minimum unit of work to be performed. Start by implementing
small individual procedures by extending the  `Procedure` interface. A procedure
can execute something and return children procedures.

Next step is to create a **Plan**. The planner, depending on some conditions will
add procedures to the plan. The executor will keep creating a new plan until there
are no more procedures. Implement the `Plan` interface and pass it to the executor.

**Always** run `mypy .` before pushing your code. It will do some type checking.
For more information check [here](https://mypy.readthedocs.io/en/stable/getting_started.html)
It will complain for some imports such as `pytest`, ignore it.

**Always** run `pytest .` before pushing your code.