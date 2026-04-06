# Homebrew Cask formula for OpenFlow
# To install: brew install --cask openflow
#
# To publish this cask:
# 1. Build the DMG: ./scripts/build-dmg.sh --sign "Developer ID Application: ..."
# 2. Notarize the DMG (see build-dmg.sh output)
# 3. Upload DMG to a GitHub Release
# 4. Update the url and sha256 below
# 5. Submit a PR to homebrew/homebrew-cask

cask "openflow" do
  version "0.1.0"
  sha256 "REPLACE_WITH_ACTUAL_SHA256"

  url "https://github.com/openflow-app/openflow/releases/download/v#{version}/OpenFlow-#{version}.dmg"
  name "OpenFlow"
  desc "Open-source voice dictation that runs locally on your Mac"
  homepage "https://github.com/openflow-app/openflow"

  depends_on macos: ">= :sonoma"

  app "OpenFlow.app"

  postflight do
    system "open", "#{appdir}/OpenFlow.app"
  end

  zap trash: [
    "~/Library/Application Support/OpenFlow",
    "~/Library/Preferences/com.openflow.app.plist",
    "~/Library/Caches/com.openflow.app",
  ]
end
