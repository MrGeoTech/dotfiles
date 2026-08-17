# Populating `ssh.yaml`

`ssh.yaml` currently holds a placeholder value so the flake evaluates before
a real key exists. To activate it:

1. Generate a fresh Ed25519 keypair **locally**, not on a shared/remote
   machine:

   ```sh
   ssh-keygen -t ed25519 -a 100 -C "<your GitHub email>" -f /tmp/id_ed25519 -N ""
   ```

2. Edit this secret in place (sops re-encrypts automatically on save):

   ```sh
   sops edit hosts/common/users/mrgeotech/secrets/ssh.yaml
   ```

   Replace the placeholder value with the contents of `/tmp/id_ed25519`
   (the **private** key), keeping the `id_ed25519: |` block-scalar
   structure.

3. Register `/tmp/id_ed25519.pub` (the **public** key) with GitHub under
   Settings > SSH and GPG keys, and with `authorized_keys` on any servers
   you want to reach with it.

4. Delete both `/tmp/id_ed25519*` files.

After a rebuild, the decrypted private key lands at `~/.ssh/id_ed25519`
(mode `0400`, owned by `mrgeotech`) and is used as the default identity for
every SSH connection -- see `home/common/core/cli/ssh.nix`.
