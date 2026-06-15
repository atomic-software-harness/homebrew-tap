class Uni < Formula
  desc "Atomic Software Harness AI client"
  # homepage は public な tap repo を指す（uni 本体は private で外部からは 404 のため）。
  homepage "https://github.com/atomic-software-harness/homebrew-tap"
  version "0.1.3"
  # binary は homebrew-tap 自身の Release に置かれる（public なので認証不要で取得可能）。
  url "https://github.com/atomic-software-harness/homebrew-tap/releases/download/v#{version}/uni-darwin-arm64.tar.gz"
  sha256 "63d8c32791168fa4873fa61fe0a983163ebba314576b28b15e59bdbd8445c884"

  # claude CLI は別経路（org 全体で配布済み）で install されている前提のため、
  # brew の依存には宣言しない。宣言すると anthropic/tap の tap が必要になり、
  # その clone で GitHub 認証を求められて install の障壁になる。必要性は caveats で告知。
  depends_on :macos => :sonoma

  def install
    # uni は実行ファイルと同階層の static/ を SPA 配信元として解決する
    # (process.execPath は symlink を解決するため、symlink 経由起動でも実体側を見る)。
    # よって uni と static を libexec に同居させ、bin/uni はそこへの symlink にする。
    # bin/uni と prefix/static のように分離すると static が隣に無く 404 になる。
    libexec.install "uni", "static"
    bin.install_symlink libexec/"uni"
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
