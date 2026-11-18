# Waza で Copilot Customizations を評価する skill のセットアップ

`evaluate-waza-copilot-customizations` skill（private skills repo 管理の明示呼び出し専用 skill）は、Copilot customization files を `waza` で static / runtime 評価するための skill です。以前の `evaluate-waza-copilot-customizations.prompt.md` の後継で、prompt 版は廃止しました。

ただし、この skill は **単体で完結する配布物ではありません**。利用には、ローカルの `waza` CLI と companion eval project が必要です。

## この skill が前提にしているもの

- `waza` CLI が `waza` コマンドとして実行できること
- PowerShell が使えること
- GitHub Copilot にサインイン済みであること
- `copilot-sdk` runtime evaluation を行える環境であること
- ローカルに Waza 評価プロジェクトが存在すること

既定では、次のローカル project を想定しています。

```text
~/waza-copilot-customization-evals
```

## 必要な companion eval project

この skill は、少なくとも次のファイルやディレクトリを参照します。

```text
.waza.yaml
evals/copilot-customizations/eval.yaml
evals/copilot-customizations/runtime-eval.yaml
evals/copilot-customizations/tasks/customization-static.yaml
evals/copilot-customizations/runtime-tasks/
evals/copilot-customizations/scripts/grade-copilot-customizations.ps1
evals/copilot-customizations/scripts/write-runtime-task.ps1
evals/copilot-customizations/scripts/write-copilot-customizations-report.ps1
results/
reports/
```

この companion project が無い場合、skill の `setup` 手順は不足資産を補う方向で動けますが、**完全な初回 bootstrap まで保証するものではありません**。

## 最低限のセットアップ

### 1. Waza CLI をインストール

推奨は `waza` standalone binary です。`azd ext install microsoft.azd.waza` でも導入できますが、バージョン差が出ることがあります。

```powershell
$bin = Join-Path $HOME 'bin'
New-Item -ItemType Directory -Force -Path $bin | Out-Null

$url = 'https://github.com/microsoft/waza/releases/latest/download/waza-windows-amd64.exe'
$dest = Join-Path $bin 'waza.exe'
Invoke-WebRequest -Uri $url -OutFile $dest

$userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
if (($userPath -split ';') -notcontains $bin) {
  [Environment]::SetEnvironmentVariable('Path', ($userPath.TrimEnd(';') + ';' + $bin), 'User')
}
if (($env:Path -split ';') -notcontains $bin) {
  $env:Path = $env:Path.TrimEnd(';') + ';' + $bin
}

waza --version
```

### 2. companion eval project を用意

この skill は stock の `waza init` だけでは足りません。`copilot customization` 用の eval assets を含む companion project を別途用意してください。

最短経路は、この repo に含めた companion template をコピーして使う方法です。

```powershell
$project = Join-Path $HOME 'waza-copilot-customization-evals'
New-Item -ItemType Directory -Force -Path $project | Out-Null
Set-Location $project

# 例: template をコピーして起点にする
# templates/waza-copilot-customization-evals/ の内容を配置
```

Template scaffold:

- [templates/waza-copilot-customization-evals/README.md](../templates/waza-copilot-customization-evals/README.md)

### 3. runtime を使うなら Copilot 側も確認

runtime evaluation は `copilot-sdk` 前提です。`static` だけならここは不要です。

```powershell
waza models
```

利用できる model が返り、VS Code / GitHub Copilot 側の認証が通っていることを確認してください。

## 使い始め方

### User Data 全体を static 評価

```powershell
$project = Join-Path $HOME 'waza-copilot-customization-evals'
Set-Location $project
$env:WAZA_CUSTOMIZATIONS_TARGET = Join-Path $HOME '.copilot'

waza run evals\copilot-customizations\eval.yaml --output results\customizations-eval.json --no-update-check -v
```

### 単一 skill を runtime 評価

```powershell
$project = Join-Path $HOME 'waza-copilot-customization-evals'
Set-Location $project
$env:WAZA_CUSTOMIZATIONS_TARGET = Join-Path $HOME '.copilot\skills\evaluate-waza-copilot-customizations\SKILL.md'

pwsh -NoProfile -ExecutionPolicy Bypass -File evals\copilot-customizations\scripts\write-runtime-task.ps1 -TargetPath $env:WAZA_CUSTOMIZATIONS_TARGET -OutputPath evals\copilot-customizations\runtime-tasks\runtime-target.yaml
waza run evals\copilot-customizations\runtime-eval.yaml --output results\runtime-customizations-eval.json --no-update-check -v
```

## 注意点

- recorded task は exploratory には便利ですが、一時パスや特定文面に過剰適合しやすいので、既定では deterministic template task を使う方が安定します
- rename 後は skill 本文だけでなく、runtime task、graders、examples、report examples も合わせて見直してください
- static gate に通ることと、安全に公開・共有できることは別なので、secret や顧客情報を含む customization は評価対象から外してください

## 共有向きにするには

この skill を他の人へ再利用しやすくするには、次のどちらかが必要です。

1. companion eval project を同じ repo で配布する
2. skill を bootstrap 対応にして、初回の eval assets 生成まで自動化する

この repo では、まず 1 のための最小 scaffold として `templates/waza-copilot-customization-evals/` を同梱しています。

現状は **skill 単体配布ではなく、companion project 前提の advanced workflow template** と考えるのが正確です。

## 参考リンク

- [microsoft/waza](https://github.com/microsoft/waza)
- [Use custom instructions in VS Code](https://code.visualstudio.com/docs/copilot/customization/custom-instructions)
- [Custom agents in VS Code](https://code.visualstudio.com/docs/copilot/customization/custom-agents)