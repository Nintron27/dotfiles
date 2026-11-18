# Git identity and SSH commit signing with the YubiKeys, for every user.
#
# Desktops sign with the local key handle (~/.ssh/nintron). Headless hosts
# (arx) have no key files, so they sign through the SSH agent forwarded from
# the desktop you connected from: the YubiKey there asks for a touch.
{ config, lib, settings, headless, ... }:
let
  me = settings.users.nintron;
  # The key public halves without their comments, for signing/verifying.
  bareKey = k: lib.concatStringsSep " " (lib.take 2 (lib.splitString " " k));
  # "~/.ssh/nintron" -> "/home/<user>/.ssh/nintron"
  expandHome = f: config.home.homeDirectory + lib.removePrefix "~" f;
in
{
  programs.git = {
    enable = true;
    settings.user = {
      inherit (me.git) name email;
    };

    signing = {
      format = "ssh";
      key = if headless then "key::${bareKey (lib.head me.sshKeys)}" else "${expandHome (lib.head me.sshIdentityFiles)}.pub";
      signByDefault = true;
    };

    # Lets `git log --show-signature` verify commits made with either YubiKey.
    settings.gpg.ssh.allowedSignersFile = "${config.xdg.configHome}/git/allowed_signers";
  };

  xdg.configFile."git/allowed_signers".text =
    lib.concatMapStrings (k: "${me.git.email} ${bareKey k}\n") me.sshKeys;
}
