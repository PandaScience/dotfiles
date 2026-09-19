# dotfiles

Dotfiles. They work for me. If you find something useful: good for you ;-)

## Setup

Dotfiles are managed by [yadm](https://yadm.io/).

On a new system simply clone this repo

```bash
yadm clone git@github.com:PandaScience/dotfiles.git
```

and set class if required

```zsh
yadm config local.class <CLASS> # e.g. work, laptop, etc..
```

Yadm will lookup user information in `~/.gitconfig`, even when overriding with

```
yadm config user.name "<Name>"
yadm config user.email "<MAIL>"
yadm config user.signingkey '<FINGERPRINT_OF_SIGNING_SUBKEY>!'
```

which places the local configuration in `~/.config/yadm/config`.

A possible workaround is to manually copy the user block into
`~/.local/share/yadm/repo.git/config`. This is where also the class information
is stored.

## Sparse checkout

Keep `README.md` and `LICENSE` in the repo, not in `$HOME`. Run these from `$HOME` — elsewhere non-cone mode fails with `please run from the toplevel directory`.

```bash
yadm sparse-checkout init --no-cone
yadm sparse-checkout set '/*' '!/README.md' '!/LICENSE'
yadm sparse-checkout list
```

Temporarily get `README.md` back, then hide it again:

```bash
yadm sparse-checkout set '/*'
# done:
yadm sparse-checkout set '/*' '!/README.md' '!/LICENSE'
```

Disable sparse checkout (full worktree, both files return):

```bash
yadm sparse-checkout disable
```

---

This README is configured as suggested [in this repo](https://github.com/seanbreckenridge/dotfiles/blob/master/.config/yadm/yadm-with-README.md)
using pre-commit and post-merge hooks.
