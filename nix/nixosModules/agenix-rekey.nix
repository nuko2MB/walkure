# Global agenix-rekey options.
# Requies hostPubkey set per host.
{ inputs, config, ... }:
{
  age.identityPaths = [ "/state/etc/ssh/ssh_host_ed25519_key" ];

  age.rekey = {
    masterIdentities = [ (inputs.self + "/secrets/age-yubikey-identity.pub") ];
    storageMode = "derivation";
    cacheDir = "/var/tmp/agenix-rekey/\"$UID\"";
  };

  walkure.ephemeral.preserve.directories = [
    {
      directory = "/var/tmp/agenix-rekey";
      mode = "1777";
    }
  ];

  # Using derivation storage mode to keep rekeyed keys out of git. (impure)
  # If remote builds are required then switching to local storage mode makes the most sense.
  # Rather than trying to nix copy the rekeyed secrets to the host.
  nix.settings.extra-sandbox-paths = [ "/var/tmp/agenix-rekey" ];
}
