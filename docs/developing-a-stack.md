# Developing & Testing a Terragrunt Stack

> **Scope** – How to
>
> 1. author a Terraform **module** →
> 2. wrap it in one or more **units** →
> 3. compose those units into a **stack** (with inter‑unit dependencies) →
> 4. nest stacks for demos →
> 5. call the published stack from an **infrastructure‑live** repo.

---

## 0  Directory map (cheat‑sheet)

```
.
├── modules/
│   └── dummy/                      # raw Terraform code (unchanged)
├── units/
│   ├── foo/                        # reusable unit wrapper for the module
│   └── bar/                        # wrapper that depends on unit foo
├── stacks/
│   └── foo-bar/                    # reusable stack (foo + bar)
└── examples/
    ├── root.hcl                    # empty include target
    ├── units/
    │   └── foo/                    # self‑contained demo unit
    │   └── bar/                    # self‑contained demo unit
    └── stacks/
        ├── foo-bar/                    # demo stack with local paths
        └── foo-bar-nested-stack/   # demo nested stack (remote paths)
```

---

## 1  Write the Terraform **module**

`modules/dummy/main.tf`:

```tf
variable "content" {}
variable "output_dir" {}

resource "local_file" "file" {
  content  = var.content
  filename = "${var.output_dir}/hi.txt"
}
```

## 2  Create a **dev unit** for rapid iteration

1. Add an empty `root.hcl` inside `examples/` so `find_in_parent_folders()` works.
2. Write `examples/units/foo/terragrunt.hcl`:

```hcl
include "root" { path = find_in_parent_folders("root.hcl") }

terraform {
  source = "${get_repo_root()}//modules/dummy"
}

inputs = {
  content    = "Testing foo unit from examples directory"
  output_dir = get_terragrunt_dir()
}
```

**Smoke‑test**

```bash
cd examples/units/foo
terragrunt apply
```

---

## 3  Author the **reusable foo unit**

`units/foo/terragrunt.hcl`:

```hcl
terraform {
  # canonical Git URL so external callers can fetch it
  source = "git::git@github.com:ConsciousML/terragrunt-template-stack.git//modules/dummy"
}

inputs = {
  content    = values.content
  output_dir = values.output_dir
}
```

## 4  Add a **bar unit** that inherits from `foo`

`units/bar/terragrunt.hcl`:

```hcl
include "root" { path = find_in_parent_folders("root.hcl") }

dependency "foo" {
  config_path  = "../foo"     # resolved after stack generation
  mock_outputs = {             # dummy output so `plan` works (module has no outputs)
    content = "placeholder"
  }
}

terraform {
  source = "git::git@github.com:ConsciousML/terragrunt-template-stack.git//modules/dummy"
}

inputs = {
  content = "Foo content: ${dependency.foo.outputs.content}"
  output_dir = values.output_dir 
}
```

## 5  Build a **demo stack** that consumes both units
`examples/stacks/foo-bar/terragrunt.stack.hcl`
```hcl
locals {
  work_dir = get_terragrunt_dir()
}

unit "foo" {
    source = "../../units/foo"
    path = "foo"

    values = {
        output_dir = get_terragrunt_dir()
        content = "Hello from foo, Terragrunt!"
    }
}

unit "bar" {
    source = "../../units/bar"
    path = "bar"

    values = {
        output_dir = get_terragrunt_dir()
    }
}
```

Generate & apply:
```bash
cd examples/stacks/foo-bar
terragrunt stack generate
terragrunt stack run apply
```

## 6  Publish the **true stack** for downstream reuse

`stacks/foo-bar/terragrunt.stack.hcl`

```hcl
unit "foo" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-stack.git//units/foo"
  path   = "foo"

  values = {
    output_dir = values.output_dir
    content    = values.content
  }
}

unit "bar" {
  source = "git::git@github.com:ConsciousML/terragrunt-template-stack.git//units/bar"
  path   = "bar"

  values = {
    output_dir = values.output_dir
  }
}
```

---

## 7  Showcase nested stacks

`examples/stacks/foo-bar-nested-stack/terragrunt.stack.hcl`
```hcl
stack "foobar" {
  source = "github.com/ConsciousML/terragrunt-template-stack//stacks/foo-bar"
  path   = "services"

  values = {
    output_dir = get_terragrunt_dir()
    content    = "Hello from foo, Terragrunt!"
  }
}
```

Run:

```bash
cd examples/stacks/foo-bar-nested-stack
terragrunt stack generate
terragrunt stack run apply
```

## 8  Call the stack from an **infrastructure-live** repo

```hcl
# live/prod/terragrunt.stack.hcl
stack "foobar" {
  source = "github.com/ConsciousML/terragrunt-template-stack//stacks/foo-bar"
  
  path   = "services"

  values = {
    output_dir = get_terragrunt_dir()
    content    = "Hello from prod!"
  }
}
```

```bash
cd live/prod
terragrunt stack generate
terragrunt stack run apply
```

## 9  Tips for fast iteration

| Need                                  | Command / Trick                                                 |
| ------------------------------------- | --------------------------------------------------------------- |
| Avoid multiple SSH passphrase prompts | `eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519`           |
| Bypass Git fetches while coding       | `TG_SOURCE=/path/to/local//units/foo terragrunt stack run plan` |
| Clean slate                           | `terragrunt stack destroy && terragrunt stack clean`            |
