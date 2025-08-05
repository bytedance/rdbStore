/*
 * Copyright (2024) Bytedance Ltd. and/or its affiliates
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { describe, beforeAll, it, expect } from '@ohos/hypium';
import { abilityDelegatorRegistry } from '@kit.TestKit';
import { UIAbility, Want } from '@kit.AbilityKit';
import {
  ColumnType,
  EventParamsBaseType,
  IEventSender,
  ILog,
  Migration,
  Rdb,
  RdbDao,
  RdbDatabase
} from '../../../../Index';
import relationalStore from '@ohos.data.relationalStore';
import {
  Child,
  Sample,
  SampleEntity,
  SampleEntity10,
  SampleEntity11,
  SampleEntity12,
  SampleEntity13,
  SampleEntity14,
  SampleEntity15,
  SampleEntity16,
  SampleEntity17,
  SampleEntity18,
  SampleEntity19,
  SampleEntity2,
  SampleEntity20,
  SampleEntity21,
  SampleEntity22,
  SampleEntity23,
  SampleEntity3,
  SampleEntity4,
  SampleEntity5,
  SampleEntity6,
  SampleEntity7,
  SampleEntity8,
  SampleEntity9
} from './model/Entity';

const delegator = abilityDelegatorRegistry.getAbilityDelegator()
const bundleName = abilityDelegatorRegistry.getArguments().bundleName;

function sleep(time: number) {
  return new Promise<void>((resolve: Function) => setTimeout(resolve, time));
}

export class Log implements ILog {
  d(tag: string, message: string): void {
    console.log(`rdbStore tag: ${tag}, message: ${message}`)
  }

  i(tag: string, message: string): void {
    console.log(`rdbStore tag: ${tag}, message: ${message}`)
  }

  w(tag: string, message: string): void {
    console.log(`rdbStore tag: ${tag}, message: ${message}`)
  }

  e(tag: string, message: string): void {
    console.log(`rdbStore tag: ${tag}, message: ${message}`)
  }
}

export class EventSender implements IEventSender {
  send(key: string, params: Record<string, EventParamsBaseType>): void {
    console.log(`rdbStore key: ${key}, params: ${JSON.stringify(params)}`)
  }
}


export default function abilityTest() {

  let db: RdbDatabase
  let dao: RdbDao<SampleEntity>
  let dao2: RdbDao<SampleEntity2>
  let dao21: RdbDao<SampleEntity2>
  let context: Context
  let startTime = 1
  let entities = [SampleEntity, SampleEntity2, SampleEntity3, SampleEntity4, SampleEntity5, SampleEntity6,
    SampleEntity7, SampleEntity8, SampleEntity9, SampleEntity10, SampleEntity11, SampleEntity12, SampleEntity13,
    SampleEntity14, SampleEntity15, SampleEntity16, SampleEntity17, SampleEntity18, SampleEntity19, SampleEntity20,
    SampleEntity21, SampleEntity22, SampleEntity23];
  beforeAll(async () => {
    //start tested ability
    const want: Want = {
      bundleName: bundleName,
      abilityName: 'TestAbility'
    }
    await delegator.startAbility(want);
    await sleep(1500);
    await delegator.getCurrentTopAbility().then(async (ability: UIAbility) => {
      context = ability.context
      startTime = Date.now()
      const migration1_2 = new Migration(1, 2).addColumn('table_x', 'column_x', ColumnType.TEXT)
      const migration2_4 = new Migration(2, 4).addIndex('index_x', 'table_x', ['column_a', 'column_b'])

      db = Rdb.databaseBuilder(context, {
        version: 1,
        dbName: 'stream.db',
        entities,
        migrations: [migration1_2, migration2_4],
        encrypt: false,
        securityLevel: relationalStore.SecurityLevel.S1,
        autoMigrate: false
      })
        .build()

      await db.initTask
      dao = await db.getDao(SampleEntity)
      dao2 = await db.getDao(SampleEntity2)
    });
  })

  describe('basic', () => {
    it('create', 0, async (done: Function) => {

      console.log(`rdbMonitor test init duration: ${Date.now() - startTime} `)
      const sample = new Sample()
      sample.name = 'mike'
      await dao.insert(sample)
      const all = await dao.queryAll()
      expect(all.length).assertLarger(0)
      console.log(`rdbMonitor test first db duration: ${Date.now() - startTime} `)

      // 检查表创建
      const tables = await db.getAllTable()

      dao = await db.getDao(SampleEntity)

      // 检查列创建
      const columns = await dao.getAllColumns()

      // 检查索引创建
      const indexes = await dao.getAllIndex()

      // 检查表创建
      const tableSql = await dao.getTableCreateSql()

      expect((tables.length > 0) && (columns.length > 0)).assertTrue()

      done()
    })

    it('insert', 0, async (done: Function) => {

      await dao.deleteAll()

      const model = new Sample()
      model.id = 1
      model.age = Date.now()
      model.bigId = BigInt(Date.now())
      await dao.insert(model)

      const model2 = new Sample()
      model2.id = 2
      model2.age = Date.now()
      model2.bigId = BigInt(Date.now())
      dao.insertSync(model2)

      const model3 = new Sample()
      model3.id = 3
      model3.age = Date.now()
      model3.bigId = BigInt(Date.now())
      await dao.batchInsert([model, model2, model3])

      const cnt = await dao.getCount()
      expect(cnt).assertEqual(3)

      // test batch insert conflict
      model3.age = 100
      model2.name = 'batch'
      model.name = 'batch-insert'
      await dao.batchInsert([model, model, model2, model3])
      const list = await dao.queryAll()
      const model1 = list.find(item => {
        return item.id == 1
      })
      const model2Query = list.find(item => {
        return item.id == 2
      })
      const model3Query = list.find(item => {
        return item.id == 3
      })
      expect(model1?.name).assertEqual('batch-insert')
      expect(model2Query?.name).assertEqual('batch')
      expect(model3Query?.age).assertEqual(100)

      const modelConstructorTest = new SampleEntity2(new Child())
      modelConstructorTest.name = 'hi'
      modelConstructorTest.child.name = 'hello'
      modelConstructorTest.child.sun.name = 'hello test'
      await dao2.insert(modelConstructorTest)
      const cntConstructorTest = await dao2.queryAll()
      expect(cntConstructorTest[0].child.sun.name).assertEqual('hello test')
      expect(cntConstructorTest[0].child.name).assertEqual('hello')
      expect(cntConstructorTest[0].name).assertEqual('hi')

      done()
    })

    it('update', 0, async (done: Function) => {

      await dao.batchDelete(dao.getPredicates())

      const model = new Sample()
      model.id = Date.now()
      model.age = 12
      model.bigId = BigInt(Date.now())
      await dao.insert(model)


      model.bigId = 3n
      model.child.name = 'j'
      const result = await dao.update(model)
      const dbValue = await dao.queryPredicate(dao.getPredicatesByKey(model))
      expect(dbValue.length).assertEqual(1)
      expect(dbValue[0].bigId).assertEqual(3n)
      expect(dbValue[0].child.name).assertEqual('j')

      model.child.name = 'c'
      model.child.sun.name = 's'
      dao.updateSync(model)
      const dbValueSync = dao.querySync(dao.getPredicatesByKey(model))
      expect(dbValueSync.length).assertEqual(1)
      expect(dbValueSync[0].child.name).assertEqual('c')
      expect(dbValueSync[0].child.sun.name).assertEqual('s')

      model.child.name = 'cc'
      model.child.sun.name = 'ss'
      const values: relationalStore.ValuesBucket = {
        'cname': 'cc',
        'sname': 'ss'
      }
      await dao.updatePartial(values, model)
      const dbValueSyncPart = dao.querySync(dao.getPredicatesByKey(model))
      expect(dbValueSyncPart.length).assertEqual(1)
      expect(dbValueSyncPart[0].child.name).assertEqual('cc')
      expect(dbValueSyncPart[0].child.sun.name).assertEqual('ss')

      done()
    })

    it('remove', 0, async (done: Function) => {
      await dao.batchDelete(dao.getPredicates())

      const model = new Sample()
      model.id = Date.now()
      model.age = Date.now()
      model.bigId = BigInt(Date.now())
      model.name = 'a'
      await dao.insert(model)
      const cnt = await dao.getCount()

      await dao.delete(model)
      const afterCnt = await dao.getCount()
      expect(afterCnt - cnt).assertEqual(-1)

      await dao.insert(model)
      dao.deleteSync(model)
      const afterInsertAndDeleteCnt = await dao.getCount()
      expect(afterInsertAndDeleteCnt - afterCnt).assertEqual(0)


      const b = new Sample()
      b.age = 1
      b.bigId = BigInt(Date.now())
      b.name = 'b'

      const c = new Sample()
      c.age = 2
      c.bigId = BigInt(Date.now())
      c.name = 'c'

      const d = new Sample()
      d.age = 3
      d.bigId = BigInt(Date.now())
      d.name = 'd'

      await dao.batchInsert([model, b, c, d])
      const afterInsertCnt = await dao.getCount()
      expect(afterInsertCnt).assertEqual(4)

      const builder = dao.predicatesBuilder()
      const nameProp = dao.getProperty('name')
      const ageProp = dao.getProperty('age')

      // (b and (c or d))
      const predicates =
        builder.where(nameProp.equalTo('b'), ...builder.or(nameProp.equalTo('c'), nameProp.equalTo('d'))).predicates
      const str1 = builder.predicatesDesc
      const deleteCnt = await dao.batchDelete(predicates)
      expect(deleteCnt).assertEqual(0)

      // (b or (c and d))
      const beforeDeleteAllCnt = await dao.getCount()
      expect(beforeDeleteAllCnt).assertEqual(4)
      const builder2 = dao.predicatesBuilder()
      const predicates2 = builder2.where(...builder2.or(nameProp.equalTo('b'),
        ...builder2.and(nameProp.equalTo('c'), nameProp.equalTo('d')))).predicates
      const str2 = builder2.predicatesDesc
      const deleteCnt2 = await dao.batchDelete(predicates2)
      const deleteAllCnt = await dao.getCount()
      expect(deleteCnt2).assertEqual(1)
      expect(deleteAllCnt).assertEqual(3)

      done()
    })

    it('query', 0, async (done: Function) => {

      dao.batchDeleteSync(dao.getPredicates())

      const b = new Sample()
      b.age = 1
      b.bigId = BigInt(Date.now())
      b.name = 'b'

      const c = new Sample()
      c.age = 2
      c.bigId = BigInt(Date.now())
      c.name = 'c'

      // 嵌套类型
      const d = new Sample()
      d.age = 3
      d.bigId = BigInt(Date.now())
      d.name = 'd'
      d.child = new Child
      d.child.name = 'dd'
      d.child.sun.bigId = 8888n

      await dao.batchInsert([b, c, d])
      const afterInsertCnt = await dao.getCount()
      expect(afterInsertCnt).assertEqual(3)

      const queryResult = dao.queryRawSqlSync('select * from SampleEntity where name = "d"')
      const queryResult2 = await dao.querySql('select * from SampleEntity where name = "d"')
      queryResult.goToNextRow()
      expect(queryResult.getRow()['name']).assertEqual('d')
      expect(queryResult2[0].child.name).assertEqual('dd')
      expect(queryResult2[0].child.sun.bigId).assertEqual(8888n)
      done()
    })

    it('pragma', 0, async (done: Function) => {
      const pageSize = await dao.execute('PRAGMA page_size')
      const journalMode = await dao.execute('PRAGMA journal_mode')
      const synchronous = await dao.execute('PRAGMA synchronous')
      const journalSizeLimit = await dao.execute('PRAGMA journal_size_limit')
      const walAutoCheckpoint = await dao.execute('PRAGMA wal_autocheckpoint')
      const foreignKeys = await dao.execute('PRAGMA foreign_keys')
      const recursiveTriggers = await dao.execute('PRAGMA recursive_triggers')
      expect(recursiveTriggers).assertLargerOrEqual(0)
      done()
    })
  })

  describe('upgrade', () => {
    it('upgrade', 0, async (done: Function) => {

      const migration1_2 = new Migration(1, 2).addColumn('SampleEntity', 'column_x', ColumnType.TEXT)
      const migration2_4 =
        new Migration(2, 4).addIndex('index_age', 'SampleEntity', ['age']).deleteColumn('SampleEntity', 'column_x')
      const migration4_5 = new Migration(4, 5).deleteIndex('index_age', 'SampleEntity')
      const migration5_6 = new Migration(5, 6).addTable('SampleEntity2')
      const migration6_7 = new Migration(6, 7).deleteTable('SampleEntity2')

      const columnCnt = await dao.getAllColumns()
      expect(columnCnt.length).assertEqual(10)

      db = Rdb.databaseBuilder(context, {
        version: 2,
        dbName: 'stream.db',
        entities: [SampleEntity],
        migrations: [migration1_2, migration2_4],
        encrypt: false,
        securityLevel: relationalStore.SecurityLevel.S1,
        autoMigrate: false
      }).setLogger(new Log())
        .setEvent(new EventSender())
        .build()

      await db.initTask
      dao = new RdbDao(db, SampleEntity)
      const columnCnt2 = await dao.getAllColumns()
      expect(columnCnt2.length).assertEqual(11)
      const indexCnt2 = await dao.getAllIndex()
      expect(indexCnt2.length).assertEqual(2)
      const dbVersion = await db.getVersion()
      expect(dbVersion).assertEqual(2)

      db = Rdb.databaseBuilder(context, {
        version: 4,
        dbName: 'stream.db',
        entities: [SampleEntity],
        migrations: [migration1_2, migration2_4],
        encrypt: false,
        securityLevel: relationalStore.SecurityLevel.S1,
        autoMigrate: false
      }).setLogger(new Log())
        .setEvent(new EventSender())
        .build()

      await db.initTask
      dao = new RdbDao(db, SampleEntity)
      const columnCnt4 = await dao.getAllColumns()
      expect(columnCnt4.length).assertEqual(10)
      const indexCnt4 = await dao.getAllIndex()
      expect(indexCnt4.length).assertEqual(3)
      const dbVersion4 = await db.getVersion()
      expect(dbVersion4).assertEqual(4)

      db = Rdb.databaseBuilder(context, {
        version: 5,
        dbName: 'stream.db',
        entities: [SampleEntity],
        migrations: [migration1_2, migration2_4, migration4_5],
        encrypt: false,
        securityLevel: relationalStore.SecurityLevel.S1,
        autoMigrate: false
      }).setLogger(new Log())
        .setEvent(new EventSender())
        .build()

      await db.initTask
      dao = new RdbDao(db, SampleEntity)
      const indexCntAfterDelete = await dao.getAllIndex()
      expect(indexCntAfterDelete.length).assertEqual(2)


      db = Rdb.databaseBuilder(context, {
        version: 6,
        dbName: 'stream.db',
        entities: [SampleEntity, SampleEntity2],
        migrations: [migration1_2, migration2_4, migration4_5, migration5_6],
        encrypt: false,
        securityLevel: relationalStore.SecurityLevel.S1,
        autoMigrate: false
      }).setLogger(new Log())
        .setEvent(new EventSender())
        .build()

      await db.initTask
      const colmn2 = await dao.getAllColumns()
      const index2 = await dao.getAllIndex()

      expect(colmn2.length).assertEqual(10)
      expect(index2.length).assertEqual(2)


      db = Rdb.databaseBuilder(context, {
        version: 7,
        dbName: 'stream.db',
        entities: [SampleEntity],
        migrations: [migration1_2, migration2_4, migration4_5, migration5_6, migration6_7],
        encrypt: false,
        securityLevel: relationalStore.SecurityLevel.S1,
        autoMigrate: false
      }).setLogger(new Log())
        .setEvent(new EventSender())
        .build()

      await db.initTask
      const tablesAfterDelete = await db.getAllTable()
      expect(tablesAfterDelete.length).assertEqual(entities.length - 1)

      done()
    })


    // it('auto_upgrade', 0, async (done: Function) => {
    //
    //
    //   db = Rdb.databaseBuilder(context, {
    //     version: 8,
    //     dbName: 'stream.db',
    //     entities: [SampleEntity],
    //     encrypt: false,
    //     securityLevel: relationalStore.SecurityLevel.S1,
    //     autoMigrate: true,
    //     migrations: []
    //   }).setLogger(new Log())
    //     .setEvent(new EventSender())
    //     .build()
    //
    //   await db.initTask
    //
    //   const dao2 = new RdbDao(db, SampleEntity)
    //   const cnt = await dao2.getAllColumns()
    //   const cntIndex = await dao2.getAllIndex()
    //   const tableCnt = await db.getAllTable()
    //   const a = 5
    //
    //
    //   done()
    // })
  })

  describe('feature', () => {
    it('defaultColumnName', 0, async (done: Function) => {
      dao21 = await db.getDao(SampleEntity21)
      let columns = await dao21.getAllColumns()
      expect(columns.includes('id')).assertEqual(true)
      expect(columns.includes('age')).assertEqual(true)
      expect(columns.includes('name')).assertEqual(true)
      expect(columns.includes('bigId')).assertEqual(true)
      done()
    })

    it('defaultTableName', 0, async (done: Function) => {
      let dao22 = await db.getDao(SampleEntity22)
      expect(dao22.config.tableName).assertEqual('SampleEntity22')
      done()
    })

    it('tableDecorator', 0, async (done: Function) => {
      let dao23 = await db.getDao(SampleEntity23)
      expect(dao23.config.tableName).assertEqual('SampleEntity23')
      done()
    })
  })
}