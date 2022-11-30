# README

## 开发配置

### 数据库创建

```
docker run -d --name db-for-mangosteen -e POSTGRES_USER=mangosteen -e POSTGRES_PASSWORD=123456 -e POSTGRES_DB=mangosteen_dev -e PGDATA=/var/lib/postgresql/data/pgdata -v mangosteen-data:/var/lib/postgresql/data --network=network1 postgres:14
```

### 数据库运行

```
docker start db-for-mangosteen
```

### 配置 gem 和 bundle 源

```
gem sources --add https://gems.ruby-china.com/ --remove https://rubygems.org/
bundle config mirror.https://rubygems.org https://gems.ruby-china.com
```

## TODO

- [ ] post /items

- [x] get /items?page&create_after&created_before

- [ ] get /items/summary?&create_after&created_before

- [x] get /tags?page

- [x] patch /tags/:id

- [x] delete /tags/:id

- [x] post /tags

- [x] get /tags/:id

- [x] post /validation_codes

- [x] post /session

- [ ] delete /session

- [ ] get /me

