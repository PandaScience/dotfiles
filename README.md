# dotfiles

Dotfiles. They work for me. If you find something useful: good for you ;-)

## Setup

Dotfiles are managed by [yadm](https://yadm.io/).

On a new system simply clone this repo

```bash
yadm clone git@github.com:PandaScience/dotfiles.git
```

and set user information for new commits (note single quotes for signing key)

```zsh
yadm config user.name "<Name>"
yadm config user.email "<MAIL>"
yadm config user.signingkey '<FINGERPRINT_OF_SIGNING_SUBKEY>!'
yadm config local.class "<CLASS>" # e.g. work, laptop, etc..
```

This README is configured as suggested [in this repo](https://github.com/seanbreckenridge/dotfiles/blob/master/.config/yadm/yadm-with-README.md)
using pre-commit and post-merge hooks.
