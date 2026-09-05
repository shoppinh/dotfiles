# Homebrew ships a vendor snippet that activates Mise before config.fish can
# finish building PATH. Keep one explicit activation at the end of config.fish.
set -gx MISE_FISH_AUTO_ACTIVATE 0
