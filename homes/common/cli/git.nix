# Git identity and SSH commit signing with the YubiKeys, for every user.
#
# Desktops sign with the local key handle (~/.ssh/nintron). Headless hosts
# (arx) have no key files, so they sign through the SSH agent forwarded from
# the desktop you connected from: the YubiKey there asks for a touch.
{ config, lib, pkgs, settings, headless, ... }:
let
  me = settings.users.nintron;
  # The key public halves without their comments, for signing/verifying.
  bareKey = k: lib.concatStringsSep " " (lib.take 2 (lib.splitString " " k));
  # "~/.ssh/nintron" -> "/home/<user>/.ssh/nintron"
  expandHome = f: config.home.homeDirectory + lib.removePrefix "~" f;

  # Keys to sign with, in order. Desktops use the local key handle files;
  # headless hosts use the forwarded agent (-U) with the public keys.
  signingKeys =
    if headless then
      map (k: "${pkgs.writeText "signing-key.pub" (bareKey k)}") me.sshKeys
    else
      map (f: "${expandHome f}.pub") me.sshIdentityFiles;

  # ssh-keygen wrapper for git: if signing with one YubiKey fails (e.g. it
  # isn't plugged in), try the next. Everything else (verifying) passes through.
  signer = pkgs.writeShellScript "git-ssh-sign" ''
    if [ "$1" != "-Y" ] || [ "$2" != "sign" ]; then
      exec ${pkgs.openssh}/bin/ssh-keygen "$@"
    fi
    # Drop git's own key choice (-f <key>, -U); we pick the key ourselves.
    args=()
    while [ $# -gt 0 ]; do
      case "$1" in
        -f) shift 2 ;;
        -U) shift ;;
        *) args+=("$1"); shift ;;
      esac
    done
    for key in ${lib.escapeShellArgs signingKeys}; do
      if ${pkgs.openssh}/bin/ssh-keygen -f "$key" ${lib.optionalString headless "-U"} "''${args[@]}"; then
        exit 0
      fi
      echo "git-ssh-sign: signing with $key failed, trying the next key" >&2
    done
    exit 1
  '';
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
      signer = "${signer}";
    };

    # Lets `git log --show-signature` verify commits made with either YubiKey.
    settings.gpg.ssh.allowedSignersFile = "${config.xdg.configHome}/git/allowed_signers";
  };

  xdg.configFile."git/allowed_signers".text =
    lib.concatMapStrings (k: "${me.git.email} ${bareKey k}\n") me.sshKeys;
}
