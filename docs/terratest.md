Install go on Linux (for other platforms, see the [installation instructions](https://go.dev/doc/install)):
```bash
wget https://go.dev/dl/go1.24.4.linux-amd64.tar.gz
rm -rf /usr/local/go

sudo tar -C /usr/local -xzf go1.24.4.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# add go to your path in .bashrc
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
```

Write the following in `examples/tests/main.tf`:
```tf
terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "2.5.3"
    }
  }

  required_version = ">= 1.9.1"
}

variable "content" {
  description = "The content to be written to the file."
  type        = string
}

variable "output_dir" {
  description = "The directory path where the file will be written."
  type        = string
}

module "dummy" {
  source     = "../../../modules/dummy"

  content    = var.content
  output_dir = var.output_dir
}

output "content" {
  value = module.dummy.content
}
```

Why creating an external test example?
We create an examples folder as a best practice to provide complete Terraform configurations that call the module and supply any required dependencies — this makes testing easier and helps others understand how to use the module. In our case, the dummy module is simple and has no external dependencies, so using an example is optional — but following the pattern keeps things consistent and scalable for future modules.

Then in `tests/dummy_test.go` add:
```go
package test

import (
    "os"
    "testing"
    "fmt"

    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/assert"
)

func TestDummyModule(t *testing.T) {
    t.Parallel() // Enable parallel execution (if running with other tests)

    tmpDir := os.TempDir()
    testOutputDir := fmt.Sprintf("%s/dummy-%s", tmpDir, t.Name())
    testContent := "Hello from Terratest!"

    terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
        TerraformDir: "../examples/tests/dummy",

        Vars: map[string]interface{}{
            "content":    testContent,
            "output_dir": testOutputDir,
        },
    })

    defer terraform.Destroy(t, terraformOptions)

    terraform.InitAndApply(t, terraformOptions)

    outputContent := terraform.Output(t, terraformOptions, "content")

    assert.Equal(t, testContent, outputContent)
}
```

Next setup the go module:
```bash
go mod init github.com/ConsciousML/terragrunt-template-stack
go get github.com/gruntwork-io/terratest/modules/terraform
go get github.com/stretchr/testify/assert
go mod tidy
```

Run the test:
```bash
go test -v ./tests/... -timeout 30m
```