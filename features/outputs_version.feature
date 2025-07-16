Feature: DeadList should output its version.
    When the --version flag is passed to DeadList
    It should return the current version before executing other commands 
    So its easy to see what I have installed

    Scenario: --version flag is passed
        Given DeadList is initialized
        When the --version flag is passed
        Then a semantic version v1.X.X etc. should be output