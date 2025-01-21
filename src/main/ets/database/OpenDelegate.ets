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

  onConfig(database: RdbDatabase, version: number): Promise<boolean> {

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
      return Promise.resolve(false)
    }

    return Promise.resolve(true)
  }

  async onDowngrade(db: relationalStore.RdbStore, database: RdbDatabase): Promise<boolean> {
    database.extension.log?.e(this.tag, `onDowngrade: ${database.config.dbName}`)
    return Promise.resolve(false)
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
        return Promise.resolve(true)
      } else {
        database.extension.log?.e(this.tag,
          `Migration: done from: ${version}, to: ${newVersion}`)
      }
    } catch (e) {
      database.extension.log?.e(this.tag,
        `Migration: error ! ${e}`)
      db.rollBack()
    }
    return Promise.resolve(false)
  }

  async onCreate(db: relationalStore.RdbStore, database: RdbDatabase): Promise<boolean> {
    database.extension.log?.i(this.tag, `onCreate: ${database.config.dbName} version: ${database.config.version}`)

    const entities = DbStructInfo.getInstance().getEntites(database.config.dbName)
    if (!(entities && entities.length > 0)) {
      return Promise.resolve(false)
    }

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
    return Promise.resolve(true)
  }
}