package tests

import (
    "os/exec"
    "testing"
    "github.com/stretchr/testify/require"
)

func TestFooBarLocalStack(t *testing.T) {
    t.Parallel()

    stackDir := "../examples/stacks/foo-bar-local"

    // Generate
    cmdGenerate := exec.Command("terragrunt", "stack", "generate")
    cmdGenerate.Dir = stackDir
    out, err := cmdGenerate.CombinedOutput()
    require.NoError(t, err, "stack generate failed: %s", string(out))

    // Apply
    cmdApply := exec.Command("terragrunt", "--non-interactive", "stack", "run", "apply")
    cmdApply.Dir = stackDir
    out, err = cmdApply.CombinedOutput()
    require.NoError(t, err, "stack run apply failed: %s", string(out))

    require.Contains(t, string(out), `content = "Foo content: Testing dummy units from examples stacks (example) (example)"`)

}