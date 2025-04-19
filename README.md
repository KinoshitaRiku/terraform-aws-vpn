# Terraform AWS VPN (OpenVPN または Twingate)

## 概要
このプロジェクトは、Terraformを使用してAWS上にVPNを構築するためのインフラコードを提供します。以下の2通りの構成に対応しています：

- **OpenVPN（EC2 上）**
  - EC2インスタンス上にOpenVPNサーバーを構築します。
  - Terraformによるプロビジョニング、およびOpenVPNの設定ファイルが含まれています。

- **Twingate（ECS 上）**
  - 作成中
  - ECSを活用してTwingateをデプロイします。
  - インターネット経由で簡単にセキュアなリモートアクセスを構築できます。

## 技術スタック
- **Terraform**：インフラの構築・管理に使用
- **Docker**：開発環境のコンテナ化に使用
- **AWS**：VPNサーバーのホスティングに使用（EC2 / ECS）
- **OpenVPN**：VPNサーバーの一つの選択肢
- **Twingate**：もう一つのVPNソリューション（モダン・ゼロトラスト対応）

## tfstate 管理
- `tfstate`ファイルは、HCP Terraformで管理されています。これにより、状態管理がクラウド上で安全に行われます。
