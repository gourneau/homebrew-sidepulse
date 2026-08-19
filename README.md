# Homebrew tap for SidePulse for Mac

[SidePulse for Mac](https://github.com/gourneau/sidepulse) is an open-source menu-bar app
for SidePulse Pro and SidePulse Dot LED hardware.

```sh
brew install --cask gourneau/sidepulse/sidepulse
```

The fully-qualified form taps and trusts in one step. If you would rather tap first, note
that Homebrew 6 requires non-official taps to be trusted explicitly:

```sh
brew tap gourneau/sidepulse
brew trust --cask gourneau/sidepulse/sidepulse
brew install --cask sidepulse
```

## Notes

- **Apple Silicon only.** The app is built arm64, so the cask declares it rather than
  letting an Intel Mac install something that cannot launch.
- **Uninstalling** runs the app's `--deregister-services` flag, which hands back the
  privileged helper and the login item. Nothing outside the app can do that, because the
  helper is registered through `SMAppService` with its plist inside the bundle.
- **`brew uninstall --zap`** will ask for your password, and asks even when there is
  nothing left to remove.
- **If you installed by hand first**, quit SidePulse and move the old copy to the Trash
  before installing the cask. Don't use `--force`: it deletes the old bundle without
  running its deregister path, which is the thing you want to happen.

## Maintenance

`.github/workflows/bump.yml` polls the app repo every six hours and commits a version and
checksum bump when a new release appears. It hashes the published asset rather than a local
rebuild, because `ditto -c -k` is not byte-reproducible.
