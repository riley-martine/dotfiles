# Git Config

We use a directory-based dispatch for git config, so multiple identities can be
seamlessly switched between. Most config should be here and checked into GitHub,
with only identity info not checked in. This is why the weird setup.

## Usage

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
