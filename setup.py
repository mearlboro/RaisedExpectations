from setuptools import find_packages, setup
setup(
    name="raised-expectations",
    version="0.0.1",
    packages=find_packages(include=["scripts", "scripts.*"]),
)
