# homebrew-tap

Homebrew tap for [Atomic Software Harness](https://github.com/atomic-software-harness) tools.

このリポジトリは Formula と、配布用バイナリの Release を兼ねてホストしている（public）。
ソースコード本体は private repo `atomic-software-harness/uni` にあり、CI / ローカル release
スクリプトがコンパイル済みバイナリだけをこの repo の Release に publish する。

## Install

```sh
brew install atomic-software-harness/tap/uni        # prd チャネル
brew install atomic-software-harness/tap/uni-dev    # dev チャネル
```

`brew tap` を明示する場合:

```sh
brew tap atomic-software-harness/tap
brew install uni
```

## 配信チャネル（prd / dev）

prd 版と dev 版は **同一マシンに併存インストールできる**。バイナリ名も状態ディレクトリも
接続先 API も別なので衝突しない（`conflicts_with` は宣言していない）。

| | prd | dev |
|---|---|---|
| Formula | `uni` | `uni-dev` |
| コマンド | `uni` | `uni-dev` |
| Release tag | `v<version>` | `dev-v<version>`（常に prerelease） |
| asset | `uni-darwin-arm64.tar.gz` | `uni-dev-darwin-arm64.tar.gz` |
| 状態ディレクトリ | `~/.uni` | `~/.uni-dev` |

チャネルを決めるのはバイナリ隣に同梱される `uni.env` のみ（バイナリ本体は両チャネルで同一）。
`uni.env` はファイル名固定で読まれるため、**両チャネルを同じ `libexec` に同居させると設定が
混ざって分離が壊れる**。Formula を分けているのはこのため。

接続先とチャネルの確認:

```sh
uni config
uni-dev config
```

## Formula

- [`Formula/uni.rb`](Formula/uni.rb) — `uni` CLI, prd チャネル (darwin-arm64)
- [`Formula/uni-dev.rb`](Formula/uni-dev.rb) — `uni-dev` CLI, dev チャネル (darwin-arm64)

## Release 手順

uni 本体 repo の `apps/uni-cli/docs/release.md` を参照。
