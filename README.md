# Introduction
Create a json object of every endpoint function in the OWASP ZAP API.

# Requirements
1. Python 3
2. pipenv: For MacOS `brew install pipenv`
3. Install python dependencies.
   1. `cd` to the project dir.
   2. Run `pipenv --three` to create a Python 3 virtual environment.
   3. Run `pipenv install` to install all dependencies in the *Pipfile*.
4. Local running instance of [ZAP](https://www.zaproxy.org/download/)

# Usage
1. Run with `pipenv run ./run.sh`
2. The generated json can be found in the current folder as `zap-api.json`.

