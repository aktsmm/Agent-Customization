---
description: "ローカルネットワーク接続トラブルシュートの手順（RDP不通、IP変更、hosts管理）"
---

<!-- author: yamapan -->
<!-- repository: n/a -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 yamapan -->

# Local Network Troubleshoot Instructions

ローカルネットワーク上のサーバーに接続できないときの調査・復旧手順。

## 優先チェック

| 優先度 | 原因 | 確認方法 |
| --- | --- | --- |
| 高 | DHCP で対象サーバーの IP が変わった | NetBIOS + ARP の MAC 照合 |
| 高 | VPN / セキュアアクセス製品がルーティングを上書き | VPN 状態、関連プロセス、ルーティング確認 |
| 中 | ファイアウォールで遮断 | ポート疎通テスト、Firewall rule 確認 |
| 中 | NIC 二重接続やメトリック問題 | Adapter / InterfaceMetric 確認 |
| 低 | サーバー側 NIC ダウンやケーブル抜け | コンソールアクセスで確認 |

## 基本疎通

```powershell
Test-Connection <host-or-ip> -Count 3
Test-NetConnection <host-or-ip> -Port 3389
Find-NetRoute -RemoteIPAddress <ip-address>
```

## DHCP による IP 変更の検出

hosts ファイルで名前解決している場合、DHCP リース更新で対象サーバーの IP が変わると接続不能になる。

```powershell
Get-Content C:\Windows\System32\drivers\etc\hosts | Select-String "<host-name>"
nbtstat -a <host-name>
arp -a | Select-String "<mac-address-fragment>"
Test-NetConnection <new-ip-address> -Port 3389
```

## VPN / セキュアアクセス影響確認

```powershell
Get-VpnConnection | Select-Object Name, ServerAddress, ConnectionStatus, TunnelType
Get-Process | Where-Object { $_.ProcessName -match 'Global|Secure|VPN|Cisco|Zscaler|Fortinet|Wireguard|OpenVPN|Tunnel' }
Get-Service | Where-Object { $_.DisplayName -match 'Global|Secure|VPN|Tunnel|Zscaler' }
Get-NetRoute -AddressFamily IPv4 |
  Where-Object { $_.DestinationPrefix -match '^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|0\.0\.0\.0)' } |
  Sort-Object RouteMetric |
  Format-Table -AutoSize
```

## NIC とインターフェース確認

```powershell
Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, LinkSpeed
Get-NetIPInterface |
  Where-Object { $_.ConnectionState -eq 'Connected' } |
  Sort-Object InterfaceMetric |
  Format-Table InterfaceAlias, AddressFamily, InterfaceMetric -AutoSize
```

## hosts 修正パターン

```powershell
$old = '<old-ip-address>'
$new = '<new-ip-address>'
$hosts = 'C:\Windows\System32\drivers\etc\hosts'
(Get-Content $hosts -Raw) -replace [regex]::Escape($old), $new |
  Set-Content $hosts -NoNewline -Encoding UTF8
ipconfig /flushdns
```

管理者権限がない場合は、管理者権限のエディタで hosts を手動編集する。

```powershell
Start-Process notepad.exe -ArgumentList "C:\Windows\System32\drivers\etc\hosts" -Verb RunAs
```

## 再発防止

| 方法 | 概要 |
| --- | --- |
| 静的 IP | サーバー側で固定 IP を設定する |
| DHCP 予約 | ルーターや DHCP サーバーで MAC アドレスに固定 IP を割り当てる |
| hosts 廃止 | DNS / mDNS / LLMNR など名前解決を見直す |

## Privacy Rule

- この公開テンプレートに実ホスト名、実 IP、顧客名、障害実績を入れない。
- 個別環境の実績はローカル専用メモに残し、`syncToGlobal` を付けない。
