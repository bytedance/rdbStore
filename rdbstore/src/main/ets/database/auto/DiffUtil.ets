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

import { IndexInfo } from '../../decoration/Entity'
import { Property } from '../../model/relation/Property'
import { TableMetaInfo } from '../../model/relation/TableMetaInfo'
import { Migration } from '../migration/Migration'
import { DiffOps, DiffType } from './DiffOps'
import { DiffResult } from './DiffResult'
import relationalStore from '@ohos.data.relationalStore'
import { DbStructInfo } from '../../model/relation/DbStructInfo'
import { ColumnType } from '../../decoration/ColumnType'
import { IndexMetaInfo } from '../../model/relation/IndexMetaInfo'

/**
 * 计算：表、列、索引 三个维度信息的变化
 */
export namespace DiffUtil {

  /**
   * 计算 && 填充 自动升级的 migration
   * 自动计算：
   * 表增加、表删除（使用自动升级时观察删除的表是否符合预期）
   * 索引增加、索引删除
   * 列增加、列删除
   * @param migration
   * @param database
   */
  export async function fillAutoUpgradeMigration(migration: Migration, database: relationalStore.RdbStore) {
    const diffResult: Array<DiffResult<Object>> = new Array
    const newTables = Array.from(DbStructInfo.getInstance().tableMap.values())
    const newTableName = new Set(newTables.map((item) => item.tableName))

    // 计算表 diff
    const currentTables = await getDiffCurrentAllTable(database)
    const tableDiff = calculateDiff<TableMetaInfo>(DiffType.TABLE, currentTables, Array.from(newTables))
    diffResult.push(...tableDiff)
    fillTableMigration(migration, tableDiff)

    // 针对已有的表，计算自动升级涉及的 列和索引
    for (const table of currentTables) {

      // 删除的表跳过
      if (!newTableName.has(table.tableName)) {
        continue
      }

      // 计算索引 diff
      const indexes = await getDiffCurrentAllIndex(database, table.tableName)
      const indexDiff = calculateDiff(DiffType.INDEX, indexes,
        DbStructInfo.getInstance().getTableMetaByName(table.tableName)!.index)
      diffResult.push(...indexDiff)
      fillIndexMigration(migration, table.tableName, indexDiff)

      // 计算列 diff
      const props = await getDiffCurrentAllColumn(database, table.tableName)
      const propDiff = calculateDiff(DiffType.COLUMN, props,
        DbStructInfo.getInstance().getPropsByName(table.tableName))
      diffResult.push(...propDiff)
      fillColumnMigration(migration, table.tableName, propDiff)
    }
  }

  /**
   * 计算 diff
   * @param olds
   * @param news
   * @returns
   */
  function calculateDiff<T extends DiffItem>(diffType: DiffType, olds: Array<T>,
    news: Array<T>): Array<DiffResult<T>> {

    const result: Array<DiffResult<T>> = new Array
    const oldSet = new Set(olds.map((item) => item.key()))
    const newSet = new Set(news.map((item) => item.key()))

    // 识别删除
    oldSet.forEach(item => {
      if (!newSet.has(item)) {
        olds.forEach(oldItem => {
          if (oldItem.key() === item) {
            result.push(new DiffResult(DiffOps.DELETE, diffType, oldItem))
          }
        })
      }
    })

    // 识别增加
    newSet.forEach(item => {
      if (!oldSet.has(item)) {
        news.forEach(newItem => {
          if (newItem.key() === item) {
            result.push(new DiffResult(DiffOps.ADD, diffType, newItem))
          }
        })
      }
    })

    return result
  }

  /**
   * 填充所有涉及表相关自动升级
   * @param migration
   * @param result
   */
  function fillTableMigration(migration: Migration, result: Array<DiffResult<TableMetaInfo>>) {
    result.forEach(item => {
      switch (item.op) {
        case DiffOps.ADD:
          migration.addTable(item.data.tableName)
          break;
        case DiffOps.DELETE:
          migration.deleteTable(item.data.tableName)
          break;
      }
    })
  }

  /**
   * 填充所有涉及列相关自动升级
   */
  function fillColumnMigration(migration: Migration, tableName: string, result: Array<DiffResult<Property>>) {
    result.forEach(item => {
      switch (item.op) {
        case DiffOps.ADD:
          migration.addColumn(tableName, item.data.columnName, item.data.type)
          break;
        case DiffOps.DELETE:
          migration.deleteColumn(tableName, item.data.columnName)
          break;
      }
    })
  }

  /**
   * 填充所有涉及索引相关自动升级
   */
  function fillIndexMigration(migration: Migration, tableName: string, result: Array<DiffResult<IndexInfo>>) {
    result.forEach(item => {
      switch (item.op) {
        case DiffOps.ADD:
          migration.addIndex(item.data.name, tableName, item.data.columnName, item.data.unique)
          break;
        case DiffOps.DELETE:
          migration.deleteIndex(item.data.name, tableName)
          break;
      }
    })
  }


  /**
   * 获取表中所有列
   */
  async function getDiffCurrentAllColumn(database: relationalStore.RdbStore,
    tableName: string): Promise<Array<Property>> {
    const props: Array<Property> = new Array
    const result = await database.querySql(`PRAGMA table_info(${tableName})`)
    if (result) {
      while (result.goToNextRow()) {
        let column = result.getRow()['name']?.toString()
        if (column) {
          const prop = new Property(tableName, ColumnType.TEXT, column, false, column, false)
          props.push(prop)
        }
      }
    }
    return props
  }

  /**
   * 获取所有表索引
   */
  async function getDiffCurrentAllIndex(database: relationalStore.RdbStore,
    tableName: string): Promise<Array<IndexMetaInfo>> {
    const indexes: Array<IndexMetaInfo> = new Array
    const result =
      await database.querySql(`SELECT * FROM sqlite_master WHERE type = "index" AND tbl_name = "${tableName}"`)
    if (result) {
      while (result.goToNextRow()) {
        const row = result.getRow()
        const index: IndexMetaInfo = new IndexMetaInfo(row['name']?.toString() ?? '', new Array)
        if (index.name && index.name.search('autoindex') < 0) {
          indexes.push(index)
        }
      }
    }
    return indexes
  }

  /**
   * 获取所有表信息
   */
  async function getDiffCurrentAllTable(database: relationalStore.RdbStore): Promise<Array<TableMetaInfo>> {
    const tables: Array<TableMetaInfo> = new Array
    const result = await database.querySql('SELECT name FROM sqlite_master WHERE type = "table" AND name NOT LIKE "sqlite_%" AND name NOT LIKE "naturalbase_rdb_%" ')
    if (result) {
      while (result.goToNextRow()) {
        const table: TableMetaInfo = new TableMetaInfo()
        table.tableName = result.getRow()['name']?.toString() ?? ''
        if (table.tableName) {
          tables.push(table)
        }
      }
    }
    return tables
  }
}

export interface DiffItem {
  key(): string
}