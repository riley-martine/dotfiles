# Git Config

## Global Pre-commit Hooks

### Motivation

[`gitleaks`](https://github.com/gitleaks/gitleaks) is a great tool. It can check
a repo for any accidentally committed secrets. It can do better though, running
before every commit to make sure those secrets are never committed in the first
place. But we don't want to set that up for every single repo individually.
That's tedious and error prone -- what if we forget one?

What we want:

- Run a global set of arbitrary pre-commit checks
- ...on already existing repos, as well as new ones
- ...with no per-repo setup
- ...regardless of a repo's existing pre-commit settings
- ...and still run any repo-local pre-commit hooks

### What to Use

Since we're adding one pre-commit check, this is a fine time to add some more as
well -- [`pre-commit`](https://pre-commit.com/) is the most widely used tool for
this outside of the `npm` ecosystem, which is why it was chosen. There are many
existing checks written for the tool.

Our goal is to run arbitrary `pre-commit` (the tool) hooks on every commit, *on
top* of whatever an individual repo uses -- `pre-commit`, `husky`, or editing
`.git/hooks`. It needs to work on all existing repos, not only new ones (so
`init.templateDir`, the suggested method, is out!).

### Usage

First, [install `pre-commit`](https://pre-commit.com/#install). I suggest using
`brew install pre-commit` if on macOS. (Though `nix` or `pipx` would probably be
fine, too.)

Next, make a global hooks dir and put our special `pre-commit` hook in it:

```shell
mkdir -p ~/.config/git/hooks
ln -s "$(realpath git/global-pre-commit-hook)" "$HOME/.config/git/hooks/pre-commit"

# If you want to also use other git hooks, like prepare-commit-msg to
# automatically fill in Jira tickets based on the branch name, link the same
# hook there as well (it has been generalized based on $0):
ln -s "$(realpath git/global-pre-commit-hook)" "$HOME/.config/git/hooks/prepare-commit-msg"

git config --global core.hooksPath "$HOME/.config/git/hooks"
```

<!-- markdownlint-disable-next-line MD033 -->
<details>

<!-- markdownlint-disable-next-line MD033 -->
<summary>If pre-commit's hooks change too much (note to self)</summary>

See changes to this file:
<https://github.com/pre-commit/pre-commit/blob/main/pre_commit/resources/hook-tmpl>

Current hook was written based off of commit
`087541cb2d7ec46e5271df53eb6edf747619e720`.

</details>

Create your `pre-commit` config and initialize the environments:

```shell
mkdir -p ~/.config/pre-commit
cp git/pre-commit-config.yaml ~/.config/pre-commit/config.yaml

# You may want to edit the config here, and add any additional hooks that
# you want to *always* run.
# See: https://pre-commit.com/hooks.html
pre-commit autoupdate --config ~/.config/pre-commit/config.yaml
```

The included hook defaults to reading config from
`~/.config/pre-commit/config.yaml`, but this can be overridden. If using a
different set of hooks per-identity, e.g. to allow committing to trunk when on
personal projects, set `global-pre-commit.configPath` in an `includeIf`'ed file.

E.g. in `~/.config/git/personal.inc`:

```gitconfig
[global-pre-commit]
    configPath = "~/.config/pre-commit/config-personal.yaml"
```

Add an [update script](/update.d/pre-commit.sh) to keep the hooks current
wherever you keep such things. You should be good to go!

Note: skipped global hooks are not displayed.

### Husky Workaround

Husky sets a local `core.hooksPath`, but we can override it. Set the following
variables in your shell config:

```shell
export GIT_CONFIG_COUNT=1
export GIT_CONFIG_KEY_0=core.hooksPath
export GIT_CONFIG_VALUE_0=~/.config/git/hooks

# Or, for fish:
set -x GIT_CONFIG_COUNT 1
set -x GIT_CONFIG_KEY_0 core.hooksPath
set -x GIT_CONFIG_VALUE_0 ~/.config/git/hooks
```

### Nix pre-commit (or other direnv-auto-install)

Sometimes projects try to be helpful and auto-install pre-commit hooks for the
pre-commit program. `pre-commit install` barfs if `core.hooksPath` is set, but
we need that. We work around this by discarding calls to `pre-commit install`.

Create `~/.config/direnv/direnvrc` with the following contents:

```bash
#!/bin/bash
strict_env

pre-commit() {
    if [[ "${1:-}" = "install" ]]; then
        echo "Patched pre-commit skipping unneeded install"
        return 0
    fi
    command pre-commit "$@"
}
export -f pre-commit
```

## Identity Dispatch

We use a directory-based dispatch for git config, so multiple identities can be
seamlessly switched between. Most config should be here and checked into GitHub,
with only identity info not checked in. This is why the weird setup.

`~/.config/git/identity.gitconfig`:

```gitconfig
[includeIf "gitdir:~/dev/"]
    path = ~/.config/git/riley-martine.gitconfig
```

`~/.config/git/riley-martine.gitconfig`:

```gitconfig
[url "github-riley-martine:"]
    insteadOf = "git@github.com:"
[user]
    name = Riley Martine
    email = riley.martine@protonmail.com
    signingkey = riley.martine@protonmail.com
[github]
    user = "riley-martine"
```

`~/.ssh/config`:

```sshconfig
Host github-riley-martine
    Hostname github.com
    User git
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_github
    IdentitiesOnly yes
```

With the `IdentityFile` created as in `setup.sh`. This can be arbitrarily
extended by the enterprising user.
