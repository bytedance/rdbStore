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


import relationalStore from '@ohos.data.relationalStore';
import { RdbError } from '../error/RdbError';
import { EventConstants } from '../EventConstant';
import { Rdb } from '../Rdb';
import { DiffUtil } from './auto/DiffUtil';
import { IOpenDelegate } from './IOpenDelegate';
import { Migration } from './migration/Migration';
import { OpenDelegate } from './OpenDelegate';
import { RdbDatabase } from './RdbDatabase';

/**
 * 管理数据库升级和创建
 */
export class RdbOpenHelper {
  private readonly database: RdbDatabase
  private readonly openDelegate: IOpenDelegate

  constructor(database: RdbDatabase) {
    this.database = database
    this.openDelegate = new OpenDelegate(database)
  }

  async getDbInstance(): Promise<relationalStore.RdbStore> {

    const startTime = Date.now()

    let rdbStore = await this.getRawRdbStore();

    let version = rdbStore.version;

    if (version > 0 && this.database.config.deprecatedFromVersion &&
      version < this.database.config.deprecatedFromVersion) {
      await relationalStore.deleteRdbStore(this.database.context, this.database.config.dbName)
      rdbStore = await this.getRawRdbStore();
      version = 0
      this.database.extension.log?.i(EventConstants.INIT_SCENE,
        `deprecated From Version ： ${this.database.config.deprecatedFromVersion}`)
    }

    await this.onConfig(this.database, version);

    // 判断是否需要自动升级
    if (version != 0 && this.database.config.autoMigrate) {
      const checkNeedUpgrade = this.database.config.version > rdbStore.version
      if (checkNeedUpgrade) {
        this.database.extension.log?.i(EventConstants.INIT_SCENE, `RdbOpenHelper getWriteDb use auto upgrade !`)
        const autoMigration = new Migration(rdbStore.version, this.database.config.version)

        // 计算且填充自动升级 migration
        await DiffUtil.fillAutoUpgradeMigration(autoMigration, rdbStore)

        this.database.config.migrations.push(autoMigration)
      }
    }

    if (version != this.database.config.version) {

      // 数据库版本高于当前版本
      if (version > this.database.config.version) {

        await this.onDowngrade(rdbStore, this.database);

        // 删除 db 文件
        await relationalStore.deleteRdbStore(this.database.context, this.database.storeConfig)

        // 重新创建 db
        rdbStore = await this.getRawRdbStore();
        version = rdbStore.version

      }

      // 数据库版本低于当前版本
      if (version < this.database.config.version) {
        try {
          // 数据库版本为 0 执行数据库创建
          if (version == 0) {
            // 创建
            await this.onCreate(rdbStore, this.database);
            rdbStore.version = this.database.config.version
          } else {
            // 升级
            const success = await this.onUpgrade(rdbStore, this.database, version, this.database.config.version);
            if (success) {
              rdbStore.version = this.database.config.version;
            } else {
              this.database.extension.log?.e(Rdb.ErrorMsg.INIT_ERROR, `upgrade error from ${version} to ${this.database.config.version}`)
            }
          }
        } catch (e) {
          this.database.extension.log?.e(Rdb.ErrorMsg.INIT_ERROR, `getWriteDb error ${JSON.stringify(e)}`)
        }
      }
    }

    // 初始化 db 参数
    await this.database.extension.tuneDbParamOptPlugin?.initTuneParams()

    // 上报初始化耗时
    this.database.monitor.eventInit(startTime)

    return rdbStore;
  }

  async onConfig(database: RdbDatabase, version: number) {
    await this.openDelegate.onConfig(database, version);
    await database.extension.openListener?.onConfig(database, version)
  }

  async onDowngrade(db: relationalStore.RdbStore, database: RdbDatabase) {
    await this.openDelegate.onDowngrade(db, database);
    await database.extension.openListener?.onDowngrade(db, database);
  }

  async onUpgrade(db: relationalStore.RdbStore, database: RdbDatabase, version: number,
    newVersion: number): Promise<boolean> {
    const success = await this.openDelegate.onUpgrade(db, database, version, newVersion)
    await database.extension.openListener?.onUpgrade(db, database, version, newVersion)
    return success
  }

  async onCreate(db: relationalStore.RdbStore, database: RdbDatabase): Promise<boolean> {
    const success = await this.openDelegate.onCreate(db, database)
    await database.extension.openListener?.onCreate(db, database)
    return success
  }

  /**
   * 数据库原生实现
   * @returns
   */
  private async getRawRdbStore(): Promise<relationalStore.RdbStore> {
    if (!this.database.config) {
      throw new RdbError(Rdb.ErrorMsg.INIT_ERROR, undefined, this.database.monitor, (param) => {
        param[EventConstants.ERROR_MSG] = 'getRawRdbStore config undefined error'
      })
    }

    let dmImpl: relationalStore.RdbStore | undefined = undefined

    try {
      dmImpl = await relationalStore.getRdbStore(this.database.context, this.database.storeConfig);
    } catch (e) {
      // db 打开失败
      throw new RdbError(Rdb.ErrorMsg.INIT_ERROR, e, this.database.monitor)
    }

    return Promise.resolve(dmImpl!)
  }
}