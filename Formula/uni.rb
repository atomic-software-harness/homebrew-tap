class Uni < Formula
  desc "Atomic Software Harness AI client"
  # homepage は public な tap repo を指す（uni 本体は private で外部からは 404 のため）。
  homepage "https://github.com/atomic-software-harness/homebrew-tap"
  version "0.1.23"
  # binary は homebrew-tap 自身の Release に置かれる（public なので認証不要で取得可能）。
  url "https://github.com/atomic-software-harness/homebrew-tap/releases/download/v#{version}/uni-darwin-arm64.tar.gz"
  sha256 "a63ebeeb60446d2f6b00a5f8fff46a830de868b191014ea9d3ba5172c157c301"
  # formula 0.1.3 は tarball 同梱の uni.env / ghostty-web を libexec に入れ損ねていた
  # （uni 起動時に env を補完する uni.env が無く getServerEnv() が必須 env 欠落で throw →
  # 無言 exit 1）。tarball は無変更で install ブロックのみ修正のため revision で再 install を促す。
  revision 1

  # claude CLI は別経路（org 全体で配布済み）で install されている前提のため、
  # brew の依存には宣言しない。宣言すると anthropic/tap の tap が必要になり、
  # その clone で GitHub 認証を求められて install の障壁になる。必要性は caveats で告知。
  depends_on :macos => :sonoma

  def install
    # uni と uni.env は全 version の tarball に必ず含まれる。
    #
    # uni.env: 配布バイナリには mise / .env.local が無いため、起動時に未設定の必須 env
    #   （MCP URL / UNI_API_URL 等）を補完する uni.env を execPath 隣から読む
    #   (process.execPath は symlink を解決するため、symlink 経由起動でも実体側を見る)。
    #   よって uni と uni.env を libexec に同居させ、bin/uni はそこへの symlink にする。
    #   分離すると uni.env が隣に無く、getServerEnv() が必須 env 欠落で throw する。
    libexec.install "uni", "uni.env"

    # static / ghostty-web は v0.1.15 までの tarball にのみ存在する。SPA は S3 + CloudFront
    # 配信へ移行し、以降の tarball は uni と uni.env の 2 つだけになった
    # （uni 側 .github/workflows/release.yml と apps/uni-cli/scripts/release-local.sh の
    # package ステップが実体）。release スクリプトは version / sha256 の行しか書き換えないため、
    # ここを無条件 install にしておくと次の release で「static が無い」と install が落ちる。
    # 新旧どちらの tarball でも通るよう、存在するときだけ install する。
    #   static:      旧 SPA 配信元。execPath 隣から解決していた
    #   ghostty-web: web terminal の実行時アセット（JS/WASM）。compiled binary には
    #                node_modules が無く、execPath 隣の ghostty-web/ から読んでいた
    %w[static ghostty-web].each do |legacy_asset|
      libexec.install legacy_asset if File.exist?(legacy_asset)
    end

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
