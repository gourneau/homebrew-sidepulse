cask "sidepulse" do
  version "0.3.0"
  sha256 "60fb38fbb28734c5d6d682b239b7ba1c08cd1eff85fa3b72689e5229b9ebf8f6"

  url "https://github.com/gourneau/sidepulse/releases/download/v#{version}/SidePulse.zip"
  name "SidePulse"
  desc "Menu bar controller for SidePulse Pro and Dot LED devices"
  homepage "https://github.com/gourneau/sidepulse"

  livecheck do
    url :url
    strategy :github_latest
  end

  # The build is not universal - scripts/package_app.sh runs a plain `swift build`,
  # which produces host-arch only. Declaring this keeps an Intel Mac from
  # installing an app it cannot launch.
  depends_on arch: :arm64
  depends_on macos: :ventura

  app "SidePulse.app"

  # Order matters and is fixed by Homebrew: quit, then signal, then script, and
  # the whole uninstall artifact runs before the app is deleted, so #{appdir} is
  # still valid when the script runs.
  #
  # quit: goes through JXA, which needs an Automation permission. If the user
  # denies it, or the upgrade is unattended, the quit is skipped SILENTLY - and
  # the old copy would keep running out of a bundle that is about to be replaced.
  # signal: uses launchctl instead, no permission involved, so it is the
  # escalation. on_upgrade re-enables it, since Homebrew skips :signal on upgrade
  # by default.
  #
  # script: is the only thing that can hand back the privileged helper. The
  # helper is registered through SMAppService with its plist inside the app
  # bundle, so there is no /Library/LaunchDaemons file for launchctl: to remove
  # and no supported way to clear the Background Task Management record from
  # outside the app.
  uninstall on_upgrade: :signal,
            quit:       "com.gourneau.SidePulse",
            signal:     ["TERM", "com.gourneau.SidePulse"],
            login_item: "SidePulse",
            script:     {
              executable:   "#{appdir}/SidePulse.app/Contents/MacOS/SidePulse",
              args:         ["--deregister-services"],
              must_succeed: false,
            }

  zap delete: "/etc/sudoers.d/sidepulse-disablesleep",
      trash:  "~/Library/Preferences/com.gourneau.SidePulse.plist"

  caveats <<~EOS
    SidePulse needs SidePulse Pro or SidePulse Dot hardware to do anything:
      https://github.com/inteliwear/sidepulse

    If you turned on lid-closed keep-awake or used Repair, the app registered a
    privileged helper. Uninstalling asks it to hand that back, but macOS may
    still show a leftover entry under System Settings -> General -> Login Items
    & Extensions. Remove it there; nothing but macOS can clear that record.

    `brew uninstall --zap` will ask for your password, and asks even when there
    is nothing to remove.
  EOS
end
