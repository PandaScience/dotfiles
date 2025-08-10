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

---

This README is configured as suggested [in this repo](https://github.com/seanbreckenridge/dotfiles/blob/master/.config/yadm/yadm-with-README.md)
using pre-commit and post-merge hooks.
