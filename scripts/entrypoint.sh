#!/bin/bash
set -euo pipefail

# Bridge stores credentials via the `pass` keychain, backed by a GPG key kept in /data.
init_keychain() {
    if [ ! -f "$HOME/.password-store/.gpg-id" ]; then
        echo "Initialising GPG key and pass store..."
        gpg --batch --passphrase '' --quick-gen-key 'ProtonMail Bridge' default default never
        pass init 'ProtonMail Bridge'
    fi
}

case "${1:-run}" in
    login)
        # One-time interactive setup: `login`, then `info` to get the bridge password.
        init_keychain
        exec bridge --cli
        ;;
    run)
        init_keychain
        # Bridge only listens on 127.0.0.1 (IMAP 1143, SMTP 1025); forward to all interfaces.
        socat TCP-LISTEN:143,fork,reuseaddr TCP:127.0.0.1:1143 &
        socat TCP-LISTEN:25,fork,reuseaddr TCP:127.0.0.1:1025 &
        exec bridge --noninteractive
        ;;
    *)
        exec "$@"
        ;;
esac
