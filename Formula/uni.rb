class Uni < Formula
  desc "Atomic Software Harness AI client"
  # homepage は public な tap repo を指す（uni 本体は private で外部からは 404 のため）。
  homepage "https://github.com/atomic-software-harness/homebrew-tap"
  version "0.1.0"
  # binary は homebrew-tap 自身の Release に置かれる（public なので認証不要で取得可能）。
  url "https://github.com/atomic-software-harness/homebrew-tap/releases/download/v#{version}/uni-darwin-arm64.tar.gz"
  sha256 "adca1cedd7d3e20f508c9db0bffaf4466d54957bbec571fece29e5bdf29d9586"

  # claude CLI は別経路（org 全体で配布済み）で install されている前提のため、
  # brew の依存には宣言しない。宣言すると anthropic/tap の tap が必要になり、
  # その clone で GitHub 認証を求められて install の障壁になる。必要性は caveats で告知。
  depends_on :macos => :sonoma

  def install
    # tar は uni-darwin-arm64/ 単一トップ階層のため、Homebrew が展開時にその中へ
    # cd する。よって install ブロック内は uni / static を直接指す（プレフィックス不要）。
    bin.install "uni"
    prefix.install "static"
  end

  def caveats
    <<~EOS
      uni runs Claude CLI under your account, so `claude` must already be
      installed and authenticated (it is not a brew dependency of uni).
      The first invocation will create ~/.uni/ and write
      ~/.uni/.claude/{settings.json,.mcp.json}.

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
