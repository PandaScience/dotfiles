# dotfiles

Dotfiles. They work for me. If you find something useful: good for you ;-)

## Setup

Dotfiles are managed by [yadm](https://yadm.io/).

On a new system simply run

```bash
yadm clone git@github.com:PandaScience/dotfiles.git
```

Set signing key for new commits via (escaping `\!` is required in zsh)

```zsh
yadm config user.signingkey "<FINGERPRINT_OF_SIGNING_SUBKEY>\!"
```

This README is configured as suggested [in this repo](https://github.com/seanbreckenridge/dotfiles/blob/master/.config/yadm/yadm-with-README.md)
using pre-commit and post-merge hooks.
