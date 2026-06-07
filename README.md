# homebrew-tap

Homebrew tap for [Atomic Software Harness](https://github.com/atomic-software-harness) tools.

このリポジトリは Formula と、配布用バイナリの Release を兼ねてホストしている（public）。
ソースコード本体は private repo `atomic-software-harness/uni` にあり、CI / ローカル release
スクリプトがコンパイル済みバイナリだけをこの repo の Release に publish する。

## Install

```sh
brew install atomic-software-harness/tap/uni
```

`brew tap` を明示する場合:

```sh
brew tap atomic-software-harness/tap
brew install uni
```

## Formula

- [`Formula/uni.rb`](Formula/uni.rb) — `uni` CLI (darwin-arm64)

## Release 手順

uni 本体 repo の `packages/uni-cli/docs/release.md` を参照。
