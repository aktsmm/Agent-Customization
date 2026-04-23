---
applyTo: "**"
---

<!-- description: ローカルネットワーク接続トラブルシュートの手順（RDP不通、IP変更、hosts管理） -->

<!-- syncToGlobal: true -->
<!-- author: yamapan -->
<!-- repository: n/a -->
<!-- license: CC BY-NC-SA 4.0 -->
<!-- copyright: Copyright (c) 2025 yamapan -->

# Local Network Troubleshoot Instructions

ローカルネットワーク上のサーバーに接続できないときの調査・復旧手順。

## 1. 典型的な原因と優先チェック順

| 優先度 | 原因 | 確認方法 |
|--------|------|----------|
| **★★★** | DHCP で対象サーバーの IP が変わった | NetBIOS + ARP の MAC 照合（後述） |
| **★★☆** | VPN / GSA がルーティングを上書き | `Get-VpnConnection`, プロセス/サービス確認 |
| **★★☆** | ファイアウォールで遮断 | `Get-NetFirewallRule`, ポート疎通テスト |
| **★☆☆** | NIC 二重接続（Wi-Fi + 有線 同一サブネット） | `Get-NetAdapter`, メトリック確認 |
| **★☆☆** | サーバー側 NIC ダウン / ケーブル抜け | コンソールアクセスで確認 |

## 2. 調査コマンド集

### 2.1 基本疎通

```powershell
Test-Connection <ホスト名 or IP> -Count 3
Test-NetConnection <ホスト名 or IP> -Port 3389
Find-NetRoute -RemoteIPAddress <IP>
```

### 2.2 DHCP による IP 変更の検出（最頻出）

```powershell
Get-Content C:\Windows\System32\drivers\etc\hosts | Select-String "<ホスト名>"
nbtstat -a <ホスト名>
arp -a | Select-String "<MACアドレスの一部>"
Test-NetConnection <新IP> -Port 3389
```

### 2.3 VPN / GSA 影響確認

```powershell
Get-VpnConnection | Select-Object Name, ServerAddress, ConnectionStatus, TunnelType
Get-Process | Where-Object { $_.ProcessName -match 'Global|GSA|Secure|VPN|Cisco|Zscaler|Fortinet|Wireguard|OpenVPN|Tunnel' }
Get-Service | Where-Object { $_.DisplayName -match 'Global|Secure|GSA|VPN|Tunnel|Zscaler' }
Get-NetRoute -AddressFamily IPv4 | Where-Object { $_.DestinationPrefix -match '^(10\.|172\.(1[6-9]|2[0-9]|3[01])\.|192\.168\.|0\.0\.0\.0)' } | Sort-Object RouteMetric | Format-Table -AutoSize
```

### 2.4 NIC・インターフェース確認

```powershell
Get-NetAdapter | Select-Object Name, InterfaceDescription, Status, LinkSpeed
Get-NetIPInterface | Where-Object { $_.ConnectionState -eq 'Connected' } | Sort-Object InterfaceMetric | Format-Table InterfaceAlias, AddressFamily, InterfaceMetric -AutoSize
```

## 3. hosts ファイル修正手順

```powershell
$old = '172.16.84.11'
$new = '172.16.83.118'
$hosts = 'C:\Windows\System32\drivers\etc\hosts'
(Get-Content $hosts -Raw) -replace [regex]::Escape($old), $new | Set-Content $hosts -NoNewline -Encoding UTF8
ipconfig /flushdns
```

## 4. 再発防止

| 方法 | 手順 | メリット |
|------|------|----------|
| **サーバー側で静的IP設定** | `New-NetIPAddress` で固定 | 簡単、サーバー単体で完結 |
| **ルーターでDHCP予約** | MAC アドレスに固定IPを割り当て | サーバー設定不要 |
| **mDNS / LLMNR 利用** | hosts 不要で名前解決 | hosts メンテ不要 |

## 5. 実績（過去の障害）

| 日付 | ホスト | 症状 | 原因 | 対処 |
|------|--------|------|------|------|
| 2026-04-18 | jam | RDP 接続不能 | DHCP で IP が `172.16.84.11` → `172.16.83.118` に変更 | hosts 修正 + DNS キャッシュクリア |
