class Uni < Formula
  desc "Atomic Software Harness AI client"
  # homepage は public な tap repo を指す（uni 本体は private で外部からは 404 のため）。
  homepage "https://github.com/atomic-software-harness/homebrew-tap"
  version "0.1.0"
  # binary は homebrew-tap 自身の Release に置かれる（public なので認証不要で取得可能）。
  url "https://github.com/atomic-software-harness/homebrew-tap/releases/download/v#{version}/uni-darwin-arm64.tar.gz"
  sha256 "adca1cedd7d3e20f508c9db0bffaf4466d54957bbec571fece29e5bdf29d9586"

  depends_on "anthropic/tap/claude" => :recommended
  depends_on :macos => :sonoma

  def install
    bin.install "uni-darwin-arm64/uni" => "uni"
    prefix.install "uni-darwin-arm64/static"
  end

  def caveats
    <<~EOS
      uni runs Claude CLI under your account. The first invocation will
      create ~/.uni/ and write ~/.uni/.claude/{settings.json,.mcp.json}.

      To start:
        uni serve

      For environment variables (UNI_HOME / MCP URLs / OTEL), see:
        https://github.com/atomic-software-harness/uni#configuration
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/uni --version")
  end
end
