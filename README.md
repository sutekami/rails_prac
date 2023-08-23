# Seven

Railsサーバサイド開発 1dayインターンのリポジトリです.

## 前提条件 📝

- Dockerとdocker composeがインストールされていること
- Gitがインストールされていること


[Dockerの公式サイト](https://docs.docker.com/get-docker/)からインストールしてください.



## 環境構築 🏗
まずはリポジトリをcloneします.

※ Windows ユーザーで、 WSL2 をバックエンドとして使い Docker を起動させる人は、WSL2 配下のディレクトリ (Ubuntu を起動したときの `/home/<ユーザー名>/` 以下など) に clone すること

(`/mnt/c/` 以下など Windows 配下のディレクトリに clone してしまうと、WSL2-Windows 間のファイルアクセスの遅さがボトルネックとなり Rails のホットリロードが効かなくなります)

```zsh
$ git clone git@github.com:eightcard/rails-1day-intern-2023.git
```

ディレクトリに移動して, imageのビルド・コンテナの立ち上げを行います.

```zsh
$ cd rails-1day-intern-2023
$ docker compose up -d --build
```

ここで全てのコンテナが立ち上がってることを確認しましょう.
```zsh
$ docker compose ps
NAME                             COMMAND                  SERVICE             STATUS              PORTS
rails-1day-intern-2023-app-1     "bash -c 'rm -f tmp/…"   app                 running             0.0.0.0:3000->3000/tcp
rails-1day-intern-2023-db-1      "docker-entrypoint.s…"   db                  running             0.0.0.0:3306->3306/tcp
rails-1day-intern-2023-minio-1   "/usr/bin/docker-ent…"   minio               running             0.0.0.0:9000-9001->9000-9001/tcp
```


確認ができたらデータベースの作成・マイグレーション・仮データの作成を行います.
```
$ docker compose exec app rails db:create db:migrate db:seed
```

ここまでコマンドを打ち終えたら[http://localhost:3000](http://localhost:3000)を開いて
サーバーが立ち上がっているか確認しましょう！

<img width="1593" src="https://user-images.githubusercontent.com/34616575/132801612-91c831b2-7305-4287-8063-9f05d20f213b.png">

## 環境構築のトラブルシューティング 🤔
Q: `Bind for 0.0.0.0:3000 failed: port is already allocated` が出て起動できない
A: 使おうとしているport番号が他のコンテナが既に使っているのが原因です。環境変数で各コンテナのport番号を任意の値に変更できるようにしてあるので、`.env.sample`をコピーしてport番号を変更してみてください。
```bash
$ cp .env.sample .env
```
```ruby
# .envの変更例
MYSQL_PORT=3309
APP_PORT=3033
MINIO_API_PORT=9000
MINIO_CONSOLE_PORT=9001
```

Q: db:seedを実行すると以下のエラーが出て画像uploadができない.
```bash
rails aborted!
Aws::S3::Errors::BadRequest: Aws::S3::Errors::BadRequest
```

A: appコンテナがminioコンテナにアクセスできていないのが原因です. まずは以下のコマンドでminioのコンテナのIPAddressを調べてください.
```bash
$ docker inspect rails-1day-intern-2023-minio-1 | grep IPAddress
  "SecondaryIPAddresses": null,
  "IPAddress": "",
          "IPAddress": "123.456.789.0",
```
次に `app/models/sample_card_image_uploader.rb` へアクセスし, s3_resourceのendpointのhost名をIPAddressに変更してください.

```ruby
def s3_resource
  @s3_resource ||= Aws::S3::Resource.new(
-   endpoint: 'http://minio:9000',
+   endpoint: 'http://123.456.789.0:9000',
    region: 'us-east-1',
    access_key_id: 'ak_eight',
    secret_access_key: 'sk_eight',
    force_path_style: true,
  )
end
```
endpointを書き換えた後, もう一度seedコマンドを実行してください.
```bash
$ docker compose exec app rails db:seed
```
