# Git Config

## Global Pre-commit Hooks

### Motivation

[`gitleaks`](https://github.com/gitleaks/gitleaks) is a great tool. It allows
you to check for any accidentally committed secrets. It can do better though,
running before every commit to make sure those secrets are never committed in
the first place. But we don't want to set that up for every single repo
individually. That's tedious and error prone -- what if we forget one?

What we want:

- Run a global set of arbitrary pre-commit checks
- ...on already existing repos as well as new ones
- ...with no per-repo setup
- ...and still run any repo-local pre-commit hooks

### What to Use

Since we're adding one pre-commit check, let's add some more as well --
[`pre-commit`](https://pre-commit.com/) is the most widely used tool for this
outside of the `npm` ecosystem, so we'll go with that.

Our goal is to run arbitrary `pre-commit` (the tool) hooks on every commit, *on
top* of whatever an individual repo uses -- `pre-commit`, `husky`, or editing
`.git/hooks`. It needs to work on all existing repos, not only new ones (so
`init.templateDir` is out!).

First, [install `pre-commit`](https://pre-commit.com/#install). I suggest using
`brew install pre-commit` if on macOS.

Next, make a global hooks dir and put our special `pre-commit` hook in it:

```shell
# Note: If using a different set of hooks per-identity, adapt as needed
mkdir -p ~/.config/git/hooks
cp git/hooks/pre-commit ~/.config/git/hooks/
git config --global core.hooksPath "$HOME/.config/git/hooks"
```

<!-- markdownlint-disable-next-line MD033 -->
<details>

<!-- markdownlint-disable-next-line MD033 -->
<summary>Re-do if pre-commit's hooks change too much</summary>

```shell
# This puts the base hook in hooks/
# Ignore the warnings about templateDir. We're doing something unsupported.
pre-commit init-templatedir ~/.config/git/
```

Add the ability to run existing hooks, by adding these lines to
`~/.config/git/hooks/pre-commit`, right before "start templated":

```bash
set -euo pipefail

if [ -f .git/hooks/pre-commit ]; then
    .git/hooks/pre-commit
fi
```

Create args for global hooks, which should be `ARGS` but with the right config,
and not failing on missing:

```bash
GLOBAL_ARGS=(hook-impl --config="$HOME/.config/pre-commit/config.yaml"
--hook-type=pre-commit)
GLOBAL_ARGS+=(--hook-dir "$HERE" -- "$@")
```

Use said args to run pre-commit global hooks before local ones:

```bash
    "$INSTALL_PYTHON" -mpre_commit "${GLOBAL_ARGS[@]}"
    # ⋮
    pre-commit "${GLOBAL_ARGS[@]}"
```

</details>

Create your `pre-commit` config and initialize the environments:

```shell
mkdir -p ~/.config/pre-commit
cp git/pre-commit-config.yaml ~/.config/pre-commit/config.yaml
pre-commit autoupdate --config ~/.config/pre-commit/config.yaml
```

Add that last line [wherever you keep your update
scripts](/update.d/pre-commit.sh). You should be good to go!

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
