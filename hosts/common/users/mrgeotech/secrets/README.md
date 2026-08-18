# Populating `ssh.yaml`

`ssh.yaml` currently holds a placeholder value so the flake evaluates before
a real key exists. See the top-level README's "SSH key setup & migration"
section for the full walkthrough (new machine, adding a machine, rotating
the key, recovering from a lost age key). Short version:

1. Generate a fresh Ed25519 keypair **locally**, not on a shared/remote
   machine:

   ```sh
   ssh-keygen -t ed25519 -a 100 -C "<your GitHub email>" -f /tmp/id_ed25519 -N ""
   ```

2. Write it into this secret non-interactively -- pasting into `sops edit`'s
   editor is easy to get wrong (e.g. vim's autoindent silently corrupting a
   pasted multi-line key), so prefer building the file directly:

   ```sh
   {
     echo "id_ed25519: |"
     sed 's/^/  /' /tmp/id_ed25519
   } > /tmp/ssh-secret.yaml
   mv /tmp/ssh-secret.yaml hosts/common/users/mrgeotech/secrets/ssh.yaml
   sops encrypt --in-place hosts/common/users/mrgeotech/secrets/ssh.yaml
   ```

   (`sops edit hosts/common/users/mrgeotech/secrets/ssh.yaml` also works if
   you'd rather edit interactively -- just make sure your editor isn't
   reindenting pasted text.)

3. Register `/tmp/id_ed25519.pub` (the **public** key) with GitHub under
   Settings > SSH and GPG keys, and with `authorized_keys` on any servers
   you want to reach with it.

4. Delete both `/tmp/id_ed25519*` files.

After a rebuild, the decrypted private key lands at `~/.ssh/id_ed25519`
(mode `0400`, owned by `mrgeotech`) and is used as the default identity for
every SSH connection -- see `home/common/core/cli/ssh.nix`. A oneshot
systemd service (`ssh-id-ed25519-pubkey.service`, wired via that secret's
`restartUnits`) derives `~/.ssh/id_ed25519.pub` from it automatically on
every activation and whenever the key changes, so there's no manual
`ssh-keygen -y` step and no risk of a stale `.pub` sibling overriding the
real key.
