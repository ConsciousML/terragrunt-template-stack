package tests

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
