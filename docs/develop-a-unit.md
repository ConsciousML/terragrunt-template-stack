Below is a battle-tested workflow that Gruntwork engineers (and most community users) follow when **building or changing a unit inside an `infrastructure-catalog` repo**. It balances fast local iteration with the guarantees you need for promotion into the live estate.

---

## 1. Create or update the underlying Terraform **module**

```
catalog/
└── modules/
    └── my-service/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

* Keep everything that can vary between environments exposed as variables.
* Add `README.md` and Terratest / OpenTofu tests if you can.

(Why? A Terragrunt **unit** is only a thin wrapper around a versioned, immutable Terraform module. The module is where the real work happens. ([terragrunt.gruntwork.io][1]))

---

## 2. Write the **unit wrapper**

```
catalog/
└── units/
    └── my-service/
        └── terragrunt.hcl
```

Typical skeleton:

```hcl
# units/my-service/terragrunt.hcl
include "root" {
  path = find_in_parent_folders("root.hcl")  # resolves in live repo
}

terraform {
  # While iterating locally override this with --source
  source = "git::git@github.com:your-org/infra-catalog.git//modules/my-service?ref=${values.version}"
}

inputs = {
  name              = values.name
  instance_type     = values.instance_type
  # …
}
```

* Use `${values.*}` everywhere so that a stack file can inject real inputs later.
* Leave the `source` pointing at **the canonical Git URL** plus `?ref=${values.version}`—you’ll override it locally in the next step.

---

## 3. Fast local iteration **inside the catalog repo**

### Option A – use the built-in `examples/terragrunt/units` pattern

Create a throw-away harness that hard-codes real values instead of `values.*`, then:

```bash
cd examples/terragrunt/units/my-service
terragrunt init && terragrunt apply   # self-contained smoke-test
```

### Option B – run the unit from a live stack but **override the source**

From a checkout of your infra-live repo:

```bash
# assume live/non-prod/terragrunt.stack.hcl already defines unit "my-service"
cd live/non-prod
TG_SOURCE=/abs/path/to/infra-catalog//units/my-service \
  terragrunt stack run plan --queue-include-unit my-service
```

`--source` / `TG_SOURCE` lets Terragrunt copy your local files on every run, giving you <1 second edit-and-rerun feedback while you develop ([terragrunt.gruntwork.io][1]).

---

## 4. Validate the unit as part of a **real stack**

Once the unit looks good in isolation, generate a stack and apply it end-to-end:

```bash
cd live/non-prod
terragrunt stack generate          # materialises .terragrunt-stack/
terragrunt stack run apply         # deploys all units in the stack
```

The stack commands copy each unit to `.terragrunt-stack/<path>`, write a `terragrunt.values.hcl` next to it, and make the `values.*` map available to the unit code ([terragrunt.gruntwork.io][2]).

---

## 5. Tag & release the catalog

1. Merge your branch.
2. `git tag v0.2.0 && git push --tags`
3. (Optional) publish a GitHub Release.

Because every unit pins `?ref=${values.version}`, nothing in `infra-live` changes until you update the `values.version` field there—a single-line PR per environment.

---

## 6. Promote the change through live environments

```hcl
# live/prod/terragrunt.stack.hcl
unit "my-service" {
  source = "git::git@github.com:your-org/infra-catalog.git//units/my-service"
  path   = "my-service-prod"
  values = {
    version        = "v0.2.0"      # bump here, commit, plan, apply
    name           = "my-service"
    instance_type  = "t4g.medium"
  }
}
```

Run:

```bash
cd live/prod
terragrunt stack run plan   # verify
terragrunt stack run apply  # deploy when ready
```

---

## 7. CI/CD & quality gates (optional but recommended)

* **Lint / validate**: `terragrunt hclfmt`, `terragrunt validate` in the unit folder.
* **Unit tests**: Terratest hitting the example directory.
* **Static checks**: tfsec, infracost.
* **Integration tests**: spin up the `.terragrunt-stack` in a sandbox AWS account.

---

### Recap

1. **Module first**, then a thin **unit** wrapper.
2. **Iterate locally** with `--source` or an example harness—no stacks needed.
3. **Generate & apply a stack** once the unit compiles to make sure `values.*` works.
4. **Tag the catalog**, bump `values.version` in live, and roll forward.

Follow that loop and you’ll have a tight feedback cycle for catalog development while still enjoying the safety guarantees of Terragrunt’s stacks when you promote to production.

[1]: https://terragrunt.gruntwork.io/docs/features/units/ "Units"
[2]: https://terragrunt.gruntwork.io/docs/features/stacks/ "Stacks"
