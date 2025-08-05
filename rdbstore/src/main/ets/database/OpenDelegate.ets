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

import { Weave } from '../decoration/Weave'
import { DbStructInfo } from '../model/relation/DbStructInfo'
import { IOpenDelegate } from './IOpenDelegate'
import { MigrationContainer } from './migration/MigrationContainer'
import { RdbDatabase } from './RdbDatabase'
import relationalStore from '@ohos.data.relationalStore'
import { SqlCompiler } from '../compile/SqlCompiler'

/**
 * 默认内置创建者
 * 运行时装饰器解析数据库信息
 */
export class OpenDelegate implements IOpenDelegate {
  private readonly tag = 'OpenDelegate'
  private database: RdbDatabase
  private migrationHelper: MigrationContainer

  constructor(database: RdbDatabase) {
    this.database = database
    this.migrationHelper = new MigrationContainer(this.database.extension)
  }

  onOpen(database: RdbDatabase): Promise<boolean> {
    return Promise.resolve(true)
  }

  async onConfig(database: RdbDatabase, version: number): Promise<boolean> {

    try {

      database.extension.log?.i(this.tag, `${database.config.dbName}: onConfig version: ${database.config.version}`)

      // 是否已经注入了初始化信息
      const dbStructInfoReady = DbStructInfo.getInstance().getDbStructInfoReady(database.config.dbName)

      // 根据数据表类信息，提取装饰器信息：表信息 && 列信息 -> DbStructInfo
      if (!dbStructInfoReady) {
        // 数据库升级 or 创建场景
        if (version != database.config.version) {
          database.extension.log?.i(this.tag, `onConfig db struct generate start !`)
          database.config.entities.forEach(item => {
            DbStructInfo.getInstance().addEntity(database.config.dbName, item)
            Weave.generateTableInfo(item)
          })
          database.extension.log?.i(this.tag, `onConfig db struct generate finish !`)
        }
      } else {
        database.extension.log?.i(this.tag, `onConfig db struct ready jump lazy init table when need !`)
      }

    } catch (e) {
      database.extension.log?.e(this.tag, `onConfig error: ${e.name} ${e.message}`)
      return false
    }

    return true
  }

  async onDowngrade(db: relationalStore.RdbStore, database: RdbDatabase): Promise<boolean> {
    database.extension.log?.e(this.tag, `onDowngrade: ${database.config.dbName}`)
    return false
  }

  async onUpgrade(db: relationalStore.RdbStore, database: RdbDatabase, version: number,
    newVersion: number): Promise<boolean> {
    database.extension.log?.i(this.tag, `onUpgrade: ${database.config.dbName}, from: ${version} to: ${newVersion}`)

    this.migrationHelper.addMigrations(this.database.config.migrations)

    const migrations = this.migrationHelper.findMigrationPath(version, newVersion);

    try {
      if (migrations) {
        db.beginTransaction()
        for (let migrations_item of migrations) {
          let sqlArray = migrations_item.buildSql()
          for (let sql of sqlArray) {
            database.extension.log?.d(this.tag, `migration sql: ${sql}`)
            await db.executeSql(sql)
          }
          database.extension.log?.i(this.tag,
            `Migration: done from: ${migrations_item.preVersion}, to: ${migrations_item.toVersion}`)
        }
        db.commit()
        return true
      } else {
        database.extension.log?.w(this.tag,
          `Migration: missing migrations from: ${version}, to: ${newVersion}`)
      }
    } catch (e) {
      database.extension.log?.e(this.tag,
        `Migration: error ! ${e.name} ${e.message}`)
      db.rollBack()
    }
    return false
  }

  async onCreate(db: relationalStore.RdbStore, database: RdbDatabase): Promise<boolean> {
    database.extension.log?.i(this.tag, `onCreate: ${database.config.dbName} version: ${database.config.version}`)

    const entities = DbStructInfo.getInstance().getEntites(database.config.dbName)
    if (!(entities && entities.length > 0)) {
      database.extension.log?.w(this.tag, `${database.config.dbName}: no valid table to create`)
      return false
    }

    try {
      db.beginTransaction()

      // 遍历所有实体表
      for (const element of entities) {

        // 创建所有表
        const sql: string = SqlCompiler.getTableCreateSql(element)
        database.extension.log?.i(this.tag, `${database.config.dbName}: onCreate excute sql: ${sql}`)
        await db.executeSql(sql)

        // 创建所有索引
        const indexes: Array<string> = SqlCompiler.getTableIndexSql(element)
        for (const sql of indexes) {
          database.extension.log?.i(this.tag, `${database.config.dbName}: onCreate excute sql: ${sql}`)
          await db.executeSql(sql)
        }
      }

      // 创建成功
      db.commit()
      return true

    } catch (e) {
      db.rollBack()
    }

    return false
  }
}