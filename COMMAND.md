# コンテナにログインしたい
```bash
$ docker compose exec app /bin/bash
```

# rails cしたい
```bash
$ docker compose exec app rails c
```

# ログを確認したい
```bash
$ docker attach rails-1day-intern-2023-app-1
```

# MySQLをターミナルで開きたい
```bash
$ docker compose exec app rails db -p
# こんな感じでSQLが書けます
MySQL [app_development]> SELECT * FROM cards;
```

## 脆弱性診断をしたい
```bash
$ docker compose exec app brakeman
# オプション指定もできます
$ docker compose exec app brakeman -q --color
```
