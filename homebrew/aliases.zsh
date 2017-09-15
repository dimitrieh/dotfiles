# ### Dump
#
# You can create a `Brewfile` from all the existing Homebrew packages you have installed with:
#
#     $ brew bundle dump
#
# The `--force` option will allow an existing `Brewfile` to be overwritten as well.
#
# ### Cleanup
#
# You can also use `Brewfile` as a whitelist. It's useful for maintainers/testers who regularly install lots of formulae. To uninstall all Homebrew formulae not listed in `Brewfile`:
#
#     $ brew bundle cleanup
#
# Unless the `--force` option is passed, formulae will be listed rather than actually uninstalled.
#
# ### Check
#
# You can check there's anything to install/upgrade in the `Brewfile` by running:
#
#     $ brew bundle check
#
# This provides a successful exit code if everything is up-to-date so is useful for scripting.

alias bcask='brew cask'
