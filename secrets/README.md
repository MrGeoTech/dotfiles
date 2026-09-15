# secrets/

Arbitrary personal files encrypted at rest with [sops](https://github.com/getsops/sops),
using the age key in `.sops.yaml` (the same one that decrypts everything under
`hosts/*/secrets/`, including the SSH identity -- see the top-level README's
"SSH key setup & migration" section).

Unlike `hosts/*/secrets/*.yaml`, files here aren't consumed by the Nix config --
they're just things you don't want sitting in the repo as plaintext (notes, an
API token, a config with a password in it, whatever). Any filename and any
content works; each file is encrypted as an opaque blob rather than parsed as
structured data.

```sh
secret edit notes.txt     # create or open an existing file in $EDITOR
secret cat notes.txt      # decrypt to stdout, no editing
```

`secret edit` decrypts to a temp file, opens it in `$EDITOR`, and re-encrypts
on save -- the copy in the repo (and in git history) is always ciphertext.
Files must sit directly in this directory (`secrets/<name>`, no
subdirectories) to match the catch-all rule in `.sops.yaml`.

Plain `sops` also works directly (`sops secrets/notes.txt`,
`sops decrypt secrets/notes.txt`) -- `secret` is just a thin wrapper that
creates the file and its parent dir for you.
