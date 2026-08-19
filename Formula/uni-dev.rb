class UniDev < Formula
  desc "Atomic Software Harness AI client (dev channel)"
  # homepage は public な tap repo を指す（uni 本体は private で外部からは 404 のため）。
  homepage "https://github.com/atomic-software-harness/homebrew-tap"
  version "0.1.18"
  # dev チャネルの tag は dev-v<version>、asset 名は uni-dev-darwin-arm64.tar.gz
  # （prd の v<version> / uni-darwin-arm64.tar.gz とは別 Release）。
  url "https://github.com/atomic-software-harness/homebrew-tap/releases/download/dev-v#{version}/uni-dev-darwin-arm64.tar.gz"
  # 初回の dev release がまだ無いためプレースホルダ（64 桁の 0）。実 asset を publish した
  # 時点で release-local.sh --dev が version と共に書き換える。
  # 書式は release-local.sh の sed（^ *sha256 "[0-9a-f]*"）に一致する必要があるため、
  # 16 進以外の文字（<REPLACE-ME> 等）を置かないこと。置くと置換が黙って空振りする。
  sha256 "1f6b902aca40ad17c74701d6c23ed6ad234d60bb46a272066607b20235a00724"

  # claude CLI は別経路（org 全体で配布済み）で install されている前提のため、
  # brew の依存には宣言しない。宣言すると anthropic/tap の tap が必要になり、
  # その clone で GitHub 認証を求められて install の障壁になる。必要性は caveats で告知。
  depends_on :macos => :sonoma

  # prd 版（uni）と同時に install できる。バイナリ名（uni / uni-dev）も UNI_HOME
  # （~/.uni / ~/.uni-dev）も別なので衝突しない。
  # conflicts_with は宣言しないこと。併存できることが本 Formula の存在理由。

  def install
    # uni は実行ファイルと同階層の uni.env を起動時に読み込んで env を補完する
    # （process.execPath は symlink を解決するため、symlink 経由の起動でも実体側を見る）。
    # よって uni-dev と uni.env を libexec に同居させ、bin/uni-dev はそこへの symlink にする。
    # 分離すると uni.env が隣に無く、必須 env 欠落で起動時に throw する。
    #
    # uni.env のファイル名は固定（baked_env.ts の resolveBakedEnvPath が
    # dirname(execPath)/uni.env を読む）。したがって prd と同じ libexec に同居させると
    # 設定が混ざってチャネル分離が壊れる。Formula を分けているのはこのため。
    libexec.install "uni-dev", "uni.env"
    bin.install_symlink libexec/"uni-dev"
  end

  def caveats
    <<~EOS
      uni-dev is the dev channel build. It connects to the dev environment and
      keeps its own state in ~/.uni-dev/ (credentials and per-execution
      workspaces are separate from the prd `uni` command).

      It runs Claude CLI under your account, so `claude` must already be
      installed and authenticated (it is not a brew dependency of uni-dev).

      To start:
        uni-dev serve

      Check which environment you are pointed at (most important when both
      channels are installed):
        uni-dev config

      For environment variables (UNI_HOME / MCP URLs / OTEL), see:
        https://github.com/atomic-software-harness/uni#configuration
    EOS
  end

  test do
    # dev チャネルの --version 出力は "<version> (dev)"。version 文字列を含むことを見る。
    assert_match version.to_s, shell_output("#{bin}/uni-dev --version")
  end
end
