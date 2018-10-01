# Workflow
## Generate file

```
$ cd path/to/package
$ ginkgo bootstrap
```

- Generate a file named `xxx_suite_test.go`
```
package books_test

import (
    . "github.com/onsi/ginkgo"
    . "github.com/onsi/gomega"
    "testing"
)

func TestBooks(t *testing.T) {
    RegisterFailHandler(Fail)
    RunSpecs(t, "Books Suite")
}
````

# Primitive
|Primitive|Description|
|:---:|:---:|
|Describe|describe the individual behaviors of your code |
|Context|exercise those behaviors under different circumstances|
|It|specify a single spec|
|BeforeEach|run before each spec|
|JustBeforeEach|run after all BeforeEach, Decouple creation from configuration|
|AfterEach|clean up in AfterEach blocks|
|Fail|mark a spec as failed|
|Specify| == It, just readable|
|CurrentGinkgoTestDescription|Print current details. GinkgoT().Log( CurrentGinkgoTestDescription())|
|BeforeSuite|run before any specs are run|
|AfterSuite|run after all the specs have run|
|By|describe in integration-style tests|

## Describe 

describe the individual behaviors of your code 

## Context

## It

placing in Describe, Context or top-level (uncommon)


## BeforeEach and AfterEach

It is also common to place assertions within BeforeEach and AfterEach blocks.

## Fail

Stop current spec, Recored failure, Ginkgo will rescure this panic.
Goroutine, in order to recover from panic, we must using GinkgoRecover before Fail.

## BeforeSuit and AfterSuite

define these at the top-level in the bootstrap file
define once in a test suite
each parallel process will run BeforeSuite and AfterSuite functions.

## By

Succeed: won't see any output
Failed: will see each step printed out up to the failure step.

# Principle

- only It, BeforeEach, JustBeforeEach, AfterEach and closure variable declarations in Container block, such as Describe and Conext

- Mistake: an assertion in a container block.