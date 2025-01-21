# 简介

鸿蒙平台数据库能力以 relationalStore 相关接口提供给开发者，rdbStore
旨在以DTO对象形式来进行数据库操作，封装数据库创建和自动升级、数据库谓词构建、查询结果反序列化、品质调优等能力，实现简单高效地进行数据库操作。  
远维方面提供：完备单元测试、品质数据打点自定义上报、链路日志等能力。
***

# 使用

 ```
ohpm install rdbStore 
 ```

技术支持：邮件 gongshijie.gongsj@bytedance.com
***

# 能力介绍

> 可参考单元测试代码进行编码

## 数据库创建

```
this.database = Rdb.databaseBuilder(context, {
  version: DBConstants.DB_VERSION,
  dbName: DBConstants.NEW_DB,
  entities: [XXXX, XXXX, XXXX, XXXX],
  migrations: [],
  encrypt: false,
  securityLevel: relationalStore.SecurityLevel.S1,
  autoMigrate: true
})
  .setLogger(new DBLog())
  .setEvent(new DBEventSender())
  .build()
```

## 数据库操作

### 插入

RdbDao#batchInsert 批量插入数据（默认为insert or replace）  
RdbDao#insert 插入数据  
RdbDao#insertSync 同步主线程插入数据

代码示范：

```
it('insert', 0, async (done: Function) => {

  const model = new Sample()
  model.id = Date.now()
  model.age = Date.now()
  model.bigId = BigInt(Date.now())
  await dao.insert(model)

  const model2 = new Sample()
  model2.id = Date.now()
  model2.age = Date.now()
  model2.bigId = BigInt(Date.now())
  dao.insertSync(model2)

  await dao.batchInsert([model, model2])
})

```

### 删除

RdbDao#delete 删除数据  
RdbDao#deleteSync 同步主线程删除  
RdbDao#batchDelete 批量通过谓词删除  
RdbDao#batchDeleteSync 批量通过谓词删除同步  
RdbDao#deleteAll 删除所有  
RdbDatabase#deleteDb 删除整个 db 文件

代码示范：

```
it('remove', 0, async (done: Function) => {
  const model = new Sample()
  model.id = Date.now()
  model.age = Date.now()
  model.bigId = BigInt(Date.now())
  model.name = 'a'
  await dao.insert(model)
  
  await dao.delete(model)

  const builder = dao.predicatesBuilder()
  const nameProp = dao.getProperty('name')
  const ageProp = dao.getProperty('age')

  // (b and (c or d))
  const predicates =
    builder.where(nameProp.equalTo('b'), ...builder.or(nameProp.equalTo('c'), nameProp.equalTo('d'))).predicates
  const deleteCnt = await dao.batchDelete(predicates)

  // (b or (c and d))
  const builder2 = dao.predicatesBuilder()
  const predicates2 = builder2.where(...builder2.or(nameProp.equalTo('b'),
    ...builder2.and(nameProp.equalTo('c'), nameProp.equalTo('d')))).predicates
  const deleteCnt2 = await dao.batchDelete(predicates2)
})
```  

### 修改

RdbDao#update 完整更新数据  
RdbDao#updatePartial 局部更新数据列  
RdbDao#updateSync 同步更新数据    
代码示范：

```
it('update', 0, async (done: Function) => {
  const model = new Sample()
  model.id = Date.now()
  model.age = 12
  model.bigId = BigInt(Date.now())
  await dao.insert(model)
  model.bigId = 3n
  model.child.name = 'j'
  
  // 异步
  await dao.update(model)
  // 同步
  dao.updateSync(model)
  // 局部更新
  model.child.name = 'cc'
  model.child.sun.name = 'ss'
  const values: relationalStore.ValuesBucket = {
    'cname': 'cc',
    'sname': 'ss'
  }
  await dao.updatePartial(values, model)
})
```

### 查找

RdbDao#predicatesBuilder 复杂查询通过 builder 构建  
RdbDao#queryPredicate 通过传入谓词来查询且解析为对应 model  
RdbDao#querySync 同步进行查询且解析为对应 model  
RdbDao#querySql Sql 语句查询且解析为对应 model  
RdbDao#queryRawSqlSync 同步执行 sql 返回原始数据结果待解析  
RdbDao#queryRawSql query sql 执行，返回原始数据结果待解析  
PredicatesBuilder#where 构建查询谓词

代码示范：

```
it('query', 0, async (done: Function) => {

  // 推荐 predicatesBuilder 查询
  const groupIdProp = dao.getProperty('groupID')
  dao.predicatesBuilder()
    .where(groupIdProp.equalTo(groupId))
    .limit(9)
    .build()
    .run()

  // sql 查询
  const queryResult = dao.queryRawSqlSync('select * from SampleEntity where name = "d"')
  const queryResult2 = await dao.querySql('select * from SampleEntity where name = "d"')
})

```

### 运维

RdbDao#getAllColumns 获取表中所有列  
RdbDao#getTableCreateSql 获取表创建语句  
RdbDao#getAllIndex 获取所有表索引  
RdbDao#getCount 查询数据库中行数量  
RdbDao#getPredicatesByKey 获取对应 model 主键的谓词  
RdbDatabase#getAllTable 获取所有表

### 品质

TuneDbParamPlugin#setJournalMode  
用于设置数据库的日志模式

1. DELETE：这是默认模式，在事务提交时删除日志。
2. TRUNCATE：在事务提交时截断日志，而不是删除。
3. MEMORY：日志仅保存在内存中。
4. WAL（Write-Ahead Logging）：先将更改记录到预写日志中，然后再异步地应用到数据库文件，提高并发性能。
   TuneDbParamPlugin#setPageSize
   设置数据库页大小，页是 SQLite 用于存储和管理数据的基本单位

TuneDbParamPlugin#setSynchronous  
插入操作时的同步模式

1. OFF：这是性能最高但最不安全的模式。在这种模式下，数据可能在系统崩溃时丢失。
2. NORMAL：这是默认模式。在提交事务时会等待操作系统将数据写入磁盘，但不等待磁盘的写入完成确认。
3. FULL：这是最安全但性能最低的模式。在提交事务时会等待操作系统将数据和元数据都写入磁盘，并等待磁盘的写入完成确认

TuneDbParamPlugin#setJournalSizeLimit  
设置日志文件大小限制

TuneDbParamPluginRdbDao#setWalAutoCheckpoint  
表示在 WAL 文件达到一定大小后自动执行检查点操作，检查点操作会将 WAL 中的更改应用到数据库文件中，并清理 WAL 文件。

***

### 升级

> 推荐开启自动升级，之后只需要修改版本号即可，无需手写 Migration

通过配置 migration 进行升级

```
const migration1_2 = new Migration(1, 2).addColumn('table_x', 'column_x', ColumnType.TEXT)
const migration2_4 = new Migration(2, 4).addIndex('index_x', 'table_x', ['column_a', 'column_b'])

this.db = Rdb.databaseBuilder(this.context, {
version: 1,
dbName: 'stream.db',
entities: [SampleEntity],
migrations: [migration1_2, migration2_4],
encrypt: false,
securityLevel: relationalStore.SecurityLevel.S1,
autoMigrate: false
}).setLogger(new DBLog())
.setEvent(new DBEventSender())
.build()
```

# License

```
Copyright (2024) Bytedance Ltd. and/or its affiliates

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```