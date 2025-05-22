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

import { RdbDatabase } from '../database/RdbDatabase'
import { DbStructInfo } from '../model/relation/DbStructInfo'
import relationalStore from '@ohos.data.relationalStore'
import { SqlCompiler } from '../compile/SqlCompiler'
import { DaoConfig } from './DaoConfig'
import { Property } from '../model/relation/Property'
import { PredicatesBuilder } from '../query/PredicatesBuilder'
import { ClassConstructor } from '../util/ClassConstructor'
import { RdbError } from '../error/RdbError'
import { Rdb } from '../Rdb'
import { Weave } from '../decoration/Weave'

/**
 * 数据库表维度操作接口
 */
export class RdbDao<Entity extends object> {
  private readonly TAG = 'RdbDao'
  private _database: RdbDatabase
  private entityCls: ClassConstructor<Entity>
  private _config: DaoConfig

  constructor(database: RdbDatabase, entityCls: ClassConstructor<Entity>) {
    this._database = database
    this.entityCls = entityCls

    // 懒加载表信息
    DbStructInfo.getInstance().addEntity(this.database.config.dbName, entityCls)
    Weave.generateTableInfo(entityCls)

    this._config = new DaoConfig(entityCls, DbStructInfo.getInstance())
  }

  /**
   * 深度为 1 叶子节点 （没有嵌套类，所有列平铺在一个类中） 直接传 property name，columnName 可不传
   * 深度 > 1 传 column name （嵌套层级下使用 name 可能存在重名字的情况，column name 保证唯一性）
   */
  public getProperty(key?: keyof Entity, columnName?: string): Property {
    const prop = columnName ?? key ?? ''
    const property = DbStructInfo.getInstance().getProperty(this.entityCls, prop.toString())

    if (!property) {
      this.database.extension.log?.e(Rdb.ErrorMsg.INPUT_CHECK_ERROR, 'getProperty error check the input key !')
      throw new RdbError(Rdb.ErrorMsg.INPUT_CHECK_ERROR, undefined, this.database.monitor)
    }
    return property
  }

  /**
   * update
   * notice：entity 中主键的字段需要有值
   */
  public async update(entity: Entity,
    conflictResolution: relationalStore.ConflictResolution = relationalStore.ConflictResolution.ON_CONFLICT_REPLACE): Promise<number> {


    const db = await this.database.getRdbImpl()

    db.beginTransaction()

    try {


      const values: relationalStore.ValuesBucket = SqlCompiler.modelToValuesBucket(this.entityCls, entity)
      const predicates: relationalStore.RdbPredicates = this.getPredicatesByKey(entity)

      const result = await db.update(values, predicates, conflictResolution)

      db.commit();

      return result

    } catch (e) {
      this.database.extension.log?.e(this.TAG, "update err_msg:" + e.message + "--err:" + e.stack)
      db.rollBack()
      throw new RdbError(Rdb.ErrorMsg.PROCESS_ERROR, e, this.database.monitor)
    }
  }

  /**
   * 局部 update
   * notice：entity 中主键的字段需要有值
   *
   * values：列名 : 字段值 比如：
   const values: relationalStore.ValuesBucket = {
   'NAME': value1,
   'AGE': value2,
   'SALARY': value3,
   'CODES': value4,
   }
   * 根据主键来匹配更新
   */
  public async updatePartial(values: relationalStore.ValuesBucket, entity: Entity,
    conflictResolution: relationalStore.ConflictResolution = relationalStore.ConflictResolution.ON_CONFLICT_REPLACE): Promise<number> {

    const db = await this.database.getRdbImpl()

    db.beginTransaction()

    try {

      const predicates: relationalStore.RdbPredicates = this.getPredicatesByKey(entity)

      const result = await db.update(values, predicates, conflictResolution)

      db.commit();

      return result

    } catch (e) {
      this.database.extension.log?.e(this.TAG, "update err_msg:" + e.message + "--err:" + e.stack)
      db.rollBack()

      throw new RdbError(Rdb.ErrorMsg.PROCESS_ERROR, e, this.database.monitor)
    }
  }

  /**
   * 根据谓词进行局部更新
   *  notice：entity 中主键的字段需要有值
   */
  public async updatePartialByPredicates(values: relationalStore.ValuesBucket,
    predicates: relationalStore.RdbPredicates,
    conflictResolution: relationalStore.ConflictResolution = relationalStore.ConflictResolution.ON_CONFLICT_REPLACE): Promise<number> {

    const db = await this.database.getRdbImpl()

    try {

      db.beginTransaction()

      const result = await db.update(values, predicates, conflictResolution)

      db.commit();

      return result

    } catch (e) {
      this.database.extension.log?.e(this.TAG, "update err_msg:" + e.message + "--err:" + e.stack)
      db.rollBack()

      throw new RdbError(Rdb.ErrorMsg.PROCESS_ERROR, e, this.database.monitor)
    }
  }

  /**
   * 同步执行 update
   *  notice：entity 中主键的字段需要有值
   */
  public updateSync(entity: Entity,
    conflictResolution: relationalStore.ConflictResolution = relationalStore.ConflictResolution.ON_CONFLICT_REPLACE): number {
    const db = this.database.getRdbImplSync()

    db.beginTransaction()

    try {

      const values: relationalStore.ValuesBucket = SqlCompiler.modelToValuesBucket(this.entityCls, entity)
      const predicates: relationalStore.RdbPredicates = this.getPredicatesByKey(entity)

      const re = db.updateSync(values, predicates, conflictResolution)

      db.commit();

      return re

    } catch (e) {
      this.database.extension.log?.e(this.TAG, "update err_msg:" + e.message + "--err:" + e.stack)
      db.rollBack()

      throw new RdbError(Rdb.ErrorMsg.PROCESS_ERROR, e, this.database.monitor)
    }
  }


  /**
   * 删除
   * notice：entity 中主键的字段需要有值
   */
  public async delete(...entities: Array<Entity>): Promise<number> {
    const db = await this.database.getRdbImpl()
    let result = 0

    db.beginTransaction()

    try {

      for (const item of entities) {
        const predicates = this.getPredicatesByKey(item)
        result = result + await db.delete(predicates)
      }

      db.commit();

      return result

    } catch (e) {
      this.database.extension.log?.e(this.TAG, "update err_msg:" + e.message + "--err:" + e.stack)
      db.rollBack()

      throw new RdbError(Rdb.ErrorMsg.PROCESS_ERROR, e, this.database.monitor)
    }
  }

  /**
   * 同步删除
   * notice：entity 中主键的字段需要有值
   */
  public deleteSync(...entities: Array<Entity>) {
    const db = this.database.getRdbImplSync()
    let result = 0

    db.beginTransaction()

    try {

      for (const item of entities) {
        const predicates = this.getPredicatesByKey(item)
        result = result + db.deleteSync(predicates)
      }

      db.commit();

      return result

    } catch (e) {
      this.database.extension.log?.e(this.TAG, "update err_msg:" + e.message + "--err:" + e.stack)
      db.rollBack()

      throw new RdbError(Rdb.ErrorMsg.PROCESS_ERROR, e, this.database.monitor)
    }
  }

  /**
   * 批量删除
   * predicates: 建议通过 predicatesBuilder 构建
   */
  public async batchDelete(predicates: relationalStore.RdbPredicates): Promise<number> {
    const db = await this.database.getRdbImpl()
    const result = await db.delete(predicates)
    return result
  }

  /**
   * 全部删除
   */
  public async deleteAll(): Promise<number> {
    const db = await this.database.getRdbImpl()
    const result = await db.delete(this.getPredicates())
    return result
  }

  /**
   * 批量删除同步
   */
  public batchDeleteSync(predicates: relationalStore.RdbPredicates): number {
    const db = this.database.getRdbImplSync()
    const result = db.deleteSync(predicates)
    return result
  }

  /**
   * 插入
   */
  public async insert(entity: Entity,
    conflict: relationalStore.ConflictResolution = relationalStore.ConflictResolution.ON_CONFLICT_REPLACE): Promise<number> {
    if (!entity) {
      return Promise.reject(`insert entity null or undefined`)
    }
    const db = await this.database.getRdbImpl()
    const values = SqlCompiler.modelToValuesBucket(this.entityCls, entity)
    const result = await db.insert(this.config.tableName, values, conflict)
    return result
  }

  /**
   * 同步执行数据库插入
   */
  public insertSync(entity: Entity,
    conflict: relationalStore.ConflictResolution = relationalStore.ConflictResolution.ON_CONFLICT_REPLACE) {
    const db = this.database.getRdbImplSync()
    const values = SqlCompiler.modelToValuesBucket(this.entityCls, entity)
    return db.insertSync(this.config.tableName, values, conflict)
  }

  /**
   * 批量插入
   * 冲突策略：insert or replace
   * @param entity
   */
  public async batchInsert(entities: Array<Entity>,
    conflict: relationalStore.ConflictResolution = relationalStore.ConflictResolution.ON_CONFLICT_REPLACE): Promise<number> {
    const db = await this.database.getRdbImpl()

    const valuesBucket = SqlCompiler.modelsToValuesBucket(this.entityCls, entities)

    if (valuesBucket && valuesBucket.length > 0) {
      return await db.batchInsert(this.config.tableName, valuesBucket)
    }

    this.database.extension.log?.e(this.TAG, `batch insert empty values bucket`)

    return Promise.resolve(0)
  }


  /**
   * 构建查询谓词
   */
  public predicatesBuilder(): PredicatesBuilder<Entity> {
    return new PredicatesBuilder(this)
  }

  /**
   * 返回所有
   */
  public async queryAll(): Promise<Array<Entity>> {
    const db = await this.database.getRdbImpl()
    const result = await db.query(this.getPredicates(), undefined, undefined, this.config.tableName)
    const re: Array<Entity> = SqlCompiler.resultToModels(this.entityCls, result)
    return re
  }

  /**
   * 返回所有 sync
   */
  public queryAllSync(): Array<Entity> {
    const db = this.database.getRdbImplSync()
    const result = db.querySync(this.getPredicates())
    const re: Array<Entity> = SqlCompiler.resultToModels(this.entityCls, result)
    return re
  }

  /**
   * 查询
   */
  public async queryPredicate(predicates: relationalStore.RdbPredicates, desc: string = ''): Promise<Array<Entity>> {
    const db = await this.database.getRdbImpl()
    const result = await db.query(predicates, undefined, desc, this.config.tableName)
    const re: Array<Entity> = SqlCompiler.resultToModels(this.entityCls, result)
    return re
  }

  /**
   * 同步查询
   * @returns
   */
  public querySync(predicates: relationalStore.RdbPredicates): Array<Entity> {
    const db = this.database.getRdbImplSync()
    const result = db.querySync(predicates)
    const re: Array<Entity> = SqlCompiler.resultToModels(this.entityCls, result)
    return re
  }

  /**
   * 只适用于 Select * 开始的语句
   */
  public async querySql(sql: string, bindArgs?: Array<relationalStore.ValueType>): Promise<Array<Entity>> {
    const db = await this.database.getRdbImpl()
    const result = await db.querySql(sql, bindArgs, this.config.tableName)
    const re: Array<Entity> = SqlCompiler.resultToModels(this.entityCls, result)
    return re
  }

  /**
   * 同步执行 sql 返回原始数据结果待解析
   * 可使用 SqlCompiler 中工具方法来解析
   */
  public queryRawSqlSync(sql: string, bindArgs?: Array<relationalStore.ValueType>): relationalStore.ResultSet {
    const db = this.database.getRdbImplSync()
    const result = db.querySqlSync(sql, bindArgs)
    return result
  }

  /**
   * query sql 执行，返回原始数据结果待解析
   * 可使用 SqlCompiler 中工具方法来解析
   */
  public async queryRawSql(sql: string,
    bindArgs?: Array<relationalStore.ValueType>): Promise<relationalStore.ResultSet> {
    const db = await this.database.getRdbImpl()
    const result = await db.querySql(sql, bindArgs, this.config.tableName)
    return result
  }

  /**
   * sql 执行
   */
  public async executeSql(sql: string, bindArgs?: Array<relationalStore.ValueType>): Promise<void> {
    const db = await this.database.getRdbImpl()
    await db.executeSql(sql, bindArgs, this.config.tableName)
  }

  /**
   * sql 执行
   */
  public async execute(sql: string, bindArgs?: Array<relationalStore.ValueType>): Promise<relationalStore.ValueType> {
    const db = await this.database.getRdbImpl()
    return await db.execute(sql, bindArgs, this.config.tableName)
  }

  /**
   * sql sync
   */
  public executeSqlSync(sql: string, bindArgs?: Array<relationalStore.ValueType>): relationalStore.ValueType {
    const db = this.database.getRdbImplSync()
    return db.executeSync(sql, bindArgs, this.config.tableName)
  }

  /**
   * 获取数据库谓词
   * @returns
   */
  public getPredicates(): relationalStore.RdbPredicates {
    return new relationalStore.RdbPredicates(this.config.tableName)
  }

  /**
   * 获取主键相同的谓词
   * @param entity
   * @returns
   */
  public getPredicatesByKey(entity: Entity): relationalStore.RdbPredicates {
    const predicates: relationalStore.RdbPredicates = this.getPredicates()

    this.config.pkProps.forEach(prop => {
      const keyValue: relationalStore.ValueType = entity[prop.name]
      if (keyValue || keyValue == 0) {
        predicates.equalTo(prop.columnName, keyValue)
      }
    })

    return predicates
  }

  /**
   * 获取表中所有列
   */
  async getAllColumns(): Promise<Array<string>> {
    const columns: Array<string> = new Array
    const db = await this.database.getRdbImpl()
    const result = await db.querySql(`PRAGMA table_info(${this.config.tableName})`, undefined, this.config.tableName)
    if (result) {
      while (result.goToNextRow()) {
        let column = result.getRow()['name']?.toString()
        if (column) {
          columns.push(column)
        }
      }
    }
    return columns
  }

  /**
   * 获取表创建语句
   */
  async getTableCreateSql(): Promise<string> {
    let sql = ''
    const db = await this.database.getRdbImpl()
    const result =
      await db.querySql(`SELECT * FROM sqlite_master WHERE type="table" AND name="${this.config.tableName}"`, undefined,
        this.config.tableName)
    if (result.goToNextRow()) {
      sql = result.getRow()['sql']?.toString() ?? ''
    }
    return sql
  }

  /**
   * 开启事务
   */
  async beginTransaction() {
    const db = await this.database.getRdbImpl()
    db.beginTransaction()
  }

  /**
   * 提交事务
   */
  async commit() {
    const db = await this.database.getRdbImpl()
    db.commit()
  }

  /**
   * 获取所有表索引
   */
  async getAllIndex(): Promise<Array<string>> {
    const indexes: Array<string> = new Array
    const db = await this.database.getRdbImpl()
    const result =
      await db.querySql(`SELECT * FROM sqlite_master WHERE type = "index" AND tbl_name = "${this.config.tableName}"`,
        undefined, this.config.tableName)
    if (result) {
      while (result.goToNextRow()) {
        const sql = result.getRow()['sql']?.toString()
        if (sql) {
          indexes.push(sql)
        }
      }
    }
    return indexes
  }

  /**
   * 查询数据库中列数量
   */
  async getCount(): Promise<number> {
    let count = 0
    const db = await this.database.getRdbImpl()
    const result =
      await db.querySql(`SELECT COUNT(*) as CNT FROM ${this.config.tableName}`, undefined, this.config.tableName)
    if (result.goToNextRow()) {
      count = result.getRow()['CNT'] as number
    }
    return count
  }

  get database() {
    return this._database
  }

  get config() {
    return this._config
  }
}