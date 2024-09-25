# Mocks

This package provide some predefined mocks for the AXUnit testing framework which you can use for your own tests.

## Install this package

```cli
apax add @simatic-ax/mocks
```

## Namespace
```
Simatic.Ax.Mocks;
```

## Mocks in this package

|Name|Signal|
|-|-|
|OffDelayMock_false | output = FALSE |
|OffDelayMock_true  | output = TRUE  |
|OnDelayMock_false  | output = FALSE |
|OnDelayMock_true   | output = TRUE  |
|OnDelayMockWithTwoTimers   | output = TRUE  |


## Markdownlint-cli

This workspace will be checked by the [markdownlint-cli](https://github.com/igorshubovych/markdownlint-cli) (there is also documented ho to install the tool) tool in the CI workflow automatically.  
To avoid, that the CI workflow fails because of the markdown linter, you can check all markdown files locally by running the markdownlint with:

```sh
markdownlint **/*.md --fix
```

## Contribution

Thanks for your interest in contributing. Anybody is free to report bugs, unclear documentation, and other problems regarding this repository in the Issues section or, even better, is free to propose any changes to this repository using Merge Requests.

## License and Legal information

Please read the [Legal information](LICENSE.md)
