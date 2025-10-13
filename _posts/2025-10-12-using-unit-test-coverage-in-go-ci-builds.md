---
layout: post
title:  "Using Unit Test Coverage In Go CI Builds"
date:   2025-10-12 00:00:00 -0400
categories: [go, automation]
---

Recently, I was setting up a Github Action on my [dice](https://github.com/abrhoda/dice) repository. I wanted to ensure that 2 things:
1. When a pull request is made into the main branch, that pull request built successfully and passed all unit tests.
2. After all unit tests passed, the total coverage of the unit tests for the entire project should be above 90%.

Go makes the first bullet point incredibly easy! `go build ./...` and `go test ./...` (or some variation of) are easy to run as part of the CI process using Github Action's `actions/setup-go@v6` action and choosing your go version/s. Go also provides the argument `-coverprofile=<filename>` that can be set in the `go test` command which will produce a coverage report of the desired filename. For example `go test ./... -coverprofile=coverage.out` will produce a `coverage.out` file in the root directory after running the tests which will have all the information about unit test coverage for the entire project. Go then provides a `go tool cover -func=<filename>` tool and command that can be used to get a breakdown of the coverage for each method in the project as well as the total test coverage on the last line (this is important!). For clarity, here's an example output of running `go tool cover -func=./out/coverage.out` on my dice project:
```
github.com/abrhoda/dice/ast.go:11:	walk		72.2%
github.com/abrhoda/dice/parser.go:14:	NewParser	100.0%
github.com/abrhoda/dice/parser.go:30:	astFromTokens	96.7%
github.com/abrhoda/dice/parser.go:78:	Parse		100.0%
github.com/abrhoda/dice/scanner.go:14:	peekByte	100.0%
github.com/abrhoda/dice/scanner.go:22:	readByte	100.0%
github.com/abrhoda/dice/scanner.go:32:	isWhiteSpace	100.0%
github.com/abrhoda/dice/scanner.go:36:	isDigit		100.0%
github.com/abrhoda/dice/scanner.go:40:	isDiceCharacter	100.0%
github.com/abrhoda/dice/scanner.go:44:	isOperator	100.0%
github.com/abrhoda/dice/scanner.go:49:	isValidByte	100.0%
github.com/abrhoda/dice/scanner.go:55:	readToken	100.0%
github.com/abrhoda/dice/token.go:25:	evaluate	100.0%
total:					(statements)	95.4%
```

For my Github Action, I wanted to use this output of `go tool cover -func=<filename>` to get the total unit test coverage percentage and ensure that it is above a threshold. To do this, I wrote the following little bahs script:

``` bash
cd "$(dirname "$0")"

main() {
  cd "$(pwd)/.."

  # TOTAL will be a decimal %
  TOTAL=$(go tool cover -func="$1" | grep total | awk '{print substr($3, 1, length($3)-1)}')
  

  if [[ `echo "$TOTAL $2" | awk '{print ($1 > $2)}'` == 1 ]];then
    echo "$TOTAL is greater than $2"
    return 0
  else
    echo "$TOTAL is less than $2"
    return 1
  fi
}

main "$@"
```
This script is invoked by running `bash ./script/coverage_threshold.bash <coverage threshold> <minimum threshold percentage>`. My Github Action has a hardcoded filename of `./out/coverage/out` where a previous step in my Github Action writes the coverage file. The Github Action also sets a minimum threshold percentage of 90.0 percent in the environment. These are arguments `$1` and `$2` respectively. `TOTAL` in the script calls the `go tool cover -func="$1"` which prints the unit test coverage for each function with the last line being the projects total unit test coverage percentage, as mentioned above. It then uses `grep` to grab the line where the word "total" appears and pass that line into `awk`. `awk` then grabs the 3rd chunk (split by whitespace) which is the percent and returns the chunk as a number, without the % sign. This is stored in a variable called `TOTAL`. `TOTAL` and `$2` (minimum threshold) are then echoed and passed into `awk` which compares them. If `$TOTAL` is more then `$2`, 0 is returned. Otherwise, 1 is returned. This follows the expected standard of a zero exit code meaning success and an exit code of non-zero to indicate a failure.

Notes:
1. `go tool cover` also provides an html view that can be used to view coverage of each file by line in an html view. While in the html view, text in green indicates that the line is covered by a test, text in red indicates that the line is not coverage by a test, and gray indicates that the line/text is ignored. What I have noticed though is that this tool considers a line covered if a single statement on the line is called. This means that a compound `if booleanStatement1 || booleanStatement2 {}` covered even if only `booleanStatement1` is used in your tests and is always true. That means that, although `booleanStatement2` is never evaluated in your tests due to `booleanStatement1` always being true, this line will be green and considered covered.

2. This script may produce unexpected results if a file within the project has a filename of total or a function with the name total. This is because of the `grep total` line. In my dice project, this works as intended because total is not a filename or a function. Just a word of caution if you use this script and your project contains a filename or function with the name total.

Github Action link of this in action: [go.yaml](https://github.com/abrhoda/dice/blob/main/.github/workflows/go.yaml) and the [Makefile](https://github.com/abrhoda/dice/blob/main/Makefile) that it references.
