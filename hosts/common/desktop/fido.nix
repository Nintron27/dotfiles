# YubiKey (FIDO2) access for every desktop user, not just the active session.
#
# By default systemd only grants the logged-in *active* session access to
# FIDO keys (uaccess). A second user (work) in another session or a terminal
# then gets "device not found" when signing or using SSH. Give the plugdev
# group (nintron and work) access instead; every use still needs a touch.
{
  services.udev.extraRules = ''
    SUBSYSTEM=="hidraw", ENV{ID_FIDO_TOKEN}=="1", GROUP="plugdev", MODE="0660"
  '';
}
