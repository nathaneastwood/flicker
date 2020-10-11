## Running the tests

To run these tests locally, in full, make sure you have set an environment variable.

```r
Sys.setenv(NOT_CRAN="true")
```

This will ensure the Spark tests run. I personally store this environment variable in a `.Renviron` file local to the project.
