# 1dayインターン当日課題資料
## まずは最初に
- 最新版の main を pull してきましょう.
- 開発環境の構築ができていない人は構築しましょう.
- 不明な点がある方はメンターに声をかけてください.

## 初期状態
環境構築が完了していると以下のような状態になっているかと思います.
- 名刺が1枚だけ表示されている.
- 名刺のデータと画像はすでにストレージに入っている.
- view 側の実装はすでに終わっている（ボタンはすでに実装済み）.

## ストレージについて
名刺画像の保存先は MinIO というストレージを使用しています. この MinIO は AWS S3 と互換性のあるサービスで画像の取得・保存・削除などの操作をすることができます. 本番環境では S3 を使っており, local 環境で同様のことをしたいときに便利です. 今回の名刺画像は `cards` というバケットに `{card_id}` で名刺画像オブジェクトが保存されています. この MinIO(S3) の使用方法については Step2 の章で説明します.

## 課題の進め方
- 基本は一人で作業しましょう.
- 各 Step が完了したらメンターの人にチェックしてもらってください.
- push しなくても大丈夫です.

## Step1: 名刺を一覧表示＆検索できるようにしよう
1. 保存されている名刺情報を一覧表示させましょう.
- `@people` に入れる情報を書き換えましょう.このときPersonモデルから取得してください.
- できるだけ SQL の発行回数を少なくすることを意識しましょう.
  - データ量が多い大規模サービスでは、SQLの大量発行はパフォーマンスの低下等の大きな問題につながってきます.
  - N+1 問題を回避するようにしましょう.

2. 名刺を検索できるようにしましょう
- 名刺の名前・メールアドレス・会社名から検索してヒットしたものだけ表示するようにしましょう.
- 「検索ボタン」を押すと `query` という変数名のパラメータに文字列が付与されて index アクションが呼ばれます.
- この際に LIKE 句で検索をかけてもらって大丈夫です.
  - これはデータ量が少ないからできることです.
  - Eightでは名刺の検索にはAWSのOpenSearchを使っています.

## Step2: 名刺画像を表示しよう
全ての名刺に名刺画像を表示させましょう.
- 画像データはMinIO(S3)に保存されています.
- `CardsController#show` にMinIO(S3)からオブジェクトを取得する実装をしましょう.
  - MinIOアクセスに必要な各種設定値は以下
    - endpoint: 'http://minio:9000'
    - region: 'us-east-1'
    - access_key_id: 'ak_eight'
    - secret_access_key: 'sk_eight'
    - bucket: 'cards'
    - force_path_style のオプションも指定して true を設定してください.
        - この設定が指定されていないと cards_{card_id} でリクエストしてしまいます
        - これだとpathに一致する画像データがなくエラーとなります
- バケットの中身を覗いてみたい人は http://localhost:9000 にアクセスしてみましょう.
  - id とパスワードは `docker-compose.yml` に記載されています.

## Step3: CSVダウンロードできるようにしよう
CSVダウンロードボタンを押すと, 名刺データの一覧CSVファイルがダウンロードされる機能を実装してください.
- CSVのヘッダーは以下
```bash
name
organization
email
department
title
```
- 名刺データをCSVファイルに書き込む処理を, `CardsController#download` に追加してください.

## Step4: 人脈管理をしよう
Eightは人脈管理ツールです.　名刺が新規で作成されたとき, 同一人物と判定される Person がいれば, 名刺をその Person に紐付けましょう.

- 以下のコマンドを叩くと、追加の名刺を取り込むことができます.
  - `$ docker compose exec app rake card_create:call_card_create_api1`
- リセットする場合は `$ docker compose exec app rails db:seed` を叩いてください.
- 同一人物に紐付けるには、新規に作成された名刺のperson_idに同一のPersonのidを紐づけましょう.
- 新規作成された名刺がどの人にも紐付かない場合, 新しいPersonを作成し, そのPersonのidを名刺に紐づけましょう.
- 新規に取り込まれる名刺が名寄せ（merge）され同一人物と判定される条件は以下の2つのケースとします.
```bash
- パターン1：氏名が完全一致 & メールアドレスが完全一致
- パターン2：メールアドレスが完全一致 & 職業関連度のスコアが 80 以上
```
- 職業関連度とは
  - 2つの職業が近い（似ている）場合はスコアが高くなります
  - 逆に2つの職業が離れている場合はスコアが低くなります
  - 例: calculation(title1, title2)
  - 職業関連度スコアを計算するモジュールはこちら側で用意しています（app/models/concerns/calculation_title_score.rb)
- 取り込まれる名刺データについて
  - 現実世界の名刺の各項目には表記揺れ（姓名の間に空白があったりなかったり、メールアドレスの場合は大文字だったり小文字だったり...などなど）が存在します.
  - 今回のデータは名刺の名前の部分に空白があるもの、ないものが存在しています.
  - 上記の表記揺れも考慮して同一人物と判定できるようにしましょう.
- 補足
  - 新規名刺取り込みのコマンドは `lib/tasks/card_create_tasks.rb` にあるように名刺データをparseして名刺作成APIを叩いています.
  - 新規で取り込まれるデータは `db/additional_data1.csv` にあります.
  - 実装が完了したらテスト用のコマンドを用意してあるので実行してください.
  - `$ docker compose exec app bin/rspec`

## Step5: Webアプリで名刺の取り込みをしよう
Step4ではrake taskで名刺を取り込みましたが、本StepではWebアプリ上でCSVファイルをアップロードして名刺を取り込んでみましょう。

- アップロード先をcards_controller#uploadとしたフォームを作成しよう
  - CSVファイルはS3にアップロードして、後述するようにJobクラスで非同期に取り込むようにしましょう
  - アップロードするファイルは、Step4で利用した`db/additional_data1.csv`を利用します
- 取り込み処理を非同期にしよう
  - 現状では非同期環境は無いので、batchという名前のコンテナを作成し、非同期環境を作成します
    - Docker imageはappコンテナで使っているものと同じもので構いません
  - キューイングサービスは `Delayed Job` を利用します
    - `bundle exec rails jobs:work` コマンドをbatchコンテナ起動時に実行し、ポーリングしましょう
  - Jobクラスを作成します
    - Step4で行った名寄せの処理をJob内で実行します
  - cards_controller#uploadからJobをエンキューします

## Appendix: RBSを使って静的型付けをしてみよう
静的型付け言語であるRBSがRuby3系から導入されました。

- rbs: 型定義をするための言語
- rbs_collection: ライブラリやgemの型定義ファイル (rbs)をまとめているgem
- steep: rbsを使って型チェックをするgem
- sig/: rbsファイルを置くディレクトリ。rbsファイルはsig/配下に置くことが推奨されている

Appendixでは、本アプリで作成したクラスやメソッドに対して型を定義してみましょう。
以下は`app/models/concerns/s3_usable.rb`のrbsファイル生成から型定義までの流れです。これらを参考にして `app/models/concerns` 配下のファイルの型定義をしてみましょう。

- sig/app/models配下にconcernsを作成する
  - `$ mkdir -p sig/app/models/concerns`
- rbsファイルを自動生成します
  - `$ docker compose exec app rbs prototype rb app/models/concerns/s3_usable.rb > sig/app/models/concerns/s3_usable.rbs`
- ライブラリの型定義を追加します
  - `$ docker compose exec app rbs collection install`
- 型のチェックを行います
  - `$ docker compose exec app steep check app/models/concerns/s3_usable.rb`
- **untypedな型を使用せず**に型定義を行い、steep checkを通すようにします
  - 参考: [https://github.com/ruby/rbs/blob/master/docs/syntax.md](https://github.com/ruby/rbs/blob/master/docs/syntax.md)
