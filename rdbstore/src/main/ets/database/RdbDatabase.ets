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

import { DatabaseBuilder } from './DatabaseBuilder';
import relationalStore from '@ohos.data.relationalStore'
import { RdbOpenHelper } from './RdbOpenHelper';
import { RdbConfig } from './RdbConfig';
import { RdbWrapper } from './RdbWrapper';
import { Rdb } from '../Rdb';
import { RdbDao } from '../dao/RdbDao';
import { Extension } from '../extension/Extension';
import { ClassConstructor } from '../util/ClassConstructor';
import { RdbMonitor } from '../util/RdbMonitor';
import { RdbError } from '../error/RdbError';

/**
 * 数据库实例
 */
export class RdbDatabase {
  private dbImpl?: RdbWrapper
  private _config: RdbConfig
  private _extension: Extension
  private _context: Context
  private _initTask: Promise<boolean> | undefined
  private _storeConfig: relationalStore.StoreConfig
  readonly monitor: RdbMonitor
  private readonly openHelper: RdbOpenHelper
  private readonly daoMap: Map<ClassConstructor<Object>, RdbDao<Object>> = new Map
  private readonly tag = 'RdbDatabase'

  constructor(builder: DatabaseBuilder) {
    this._config = builder.config
    this._extension = builder.extension
    this._context = builder.context
    this.openHelper = new RdbOpenHelper(this)
    this.monitor = new RdbMonitor(this.extension)
    this._storeConfig = {
      name: this.config.dbName,
      securityLevel: this.config.securityLevel
    }
  }

  /**
   * 数据库的初始化
   */
  private async init(): Promise<boolean> {
    if (!this._initTask) {
      this._initTask = new Promise(async (resolve, reject) => {
        if (this.initDone()) {
          resolve(true)
        }
        this.extension.log?.i(this.tag, `init`)
        this.dbImpl = new RdbWrapper(await this.getDbInstance(), this.monitor, this.extension)
        this.extension.log?.i(this.tag, `init finish`)
        if (this.dbImpl) {
          resolve(true)
        }
      })
    }

    return this._initTask
  }

  /**
   * 获取表查询能力提供者
   * @param entityCls
   * @returns
   */
  async getDao<Entity extends object>(entityCls: ClassConstructor<Entity>): Promise<RdbDao<Entity>> {

    await this.initTask

    let dao = this.daoMap.get(entityCls)

    if (!dao) {
      dao = new RdbDao<Entity>(this, entityCls)
      this.daoMap.set(entityCls, dao)
    }

    return dao as RdbDao<Entity>
  }

  /**
   * 获取 db 内所有 dao
   */
  get allDao(): IterableIterator<RdbDao<object>> {
    return this.daoMap.values()
  }

  /**
   * 初始化完成
   * @returns
   */
  private initDone(): boolean {
    if (this.dbImpl) {
      return true
    }
    return false
  }

  /**
   * 数据库创建
   * @returns
   */
  private async getDbInstance(): Promise<relationalStore.RdbStore> {
    return await this.openHelper.getDbInstance()
  }

  /**
   * 获取数据库配置
   * @returns
   */
  get config() {
    return this._config
  }

  /**
   * 数据库 context
   * @returns
   */
  get context() {
    return this._context
  }

  /**
   * 数据库配置
   */
  get storeConfig() {
    return this._storeConfig
  }

  /**
   * 拓展能力集
   * @returns
   */
  get extension() {
    return this._extension
  }

  /**
   * 初始化任务
   * @returns
   */
  get initTask() {
    this.init()
    return this._initTask
  }

  /**
   * 数据库实例
   * @returns
   */
  async getRdbImpl() {
    await this.initTask
    return this.dbImpl!
  }

  /**
   * 数据库实例 同步获取
   * @returns
   */
  getRdbImplSync() {
    if (!this.dbImpl) {
      this.extension.log?.e(this.tag, Rdb.ErrorMsg.INIT_ERROR)
      throw new RdbError(Rdb.ErrorMsg.INIT_ERROR, undefined, this.monitor)
    }
    return this.dbImpl!
  }

  /**
   * 返回所有数据库中表名
   * @returns
   */
  async getAllTable(): Promise<Array<string>> {
    const tables: Array<string> = new Array
    await this.initTask
    const result =
      await this.dbImpl?.querySql('SELECT name FROM sqlite_master WHERE type = "table" AND name NOT LIKE "sqlite_%" ')
    if (result) {
      while (result.goToNextRow()) {
        let tableName = result.getRow()['name']?.toString()
        if (tableName) {
          tables.push(tableName)
        }
      }
    }
    return tables
  }

  /**
   * version
   */
  async getVersion(): Promise<number> {
    const db = await this.getRdbImpl()
    return db.getVersion()
  }

  /**
   * delete db
   */
  async deleteDb(): Promise<void> {
    await relationalStore.deleteRdbStore(this.context, this.storeConfig)
  }
}