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

import { SqlCompiler } from '../../compile/SqlCompiler';
import { ColumnType } from '../../decoration/ColumnType';
import { DbStructInfo } from '../../model/relation/DbStructInfo';

/**
 * 指定版本之间的升级方式
 * Migration(1, 2) 代表：从1版本升级到2版本所需要执行的升级
 */
export class Migration {
  /**
   * 待升级的起始版本
   */
  private _preVersion: number = 1;
  /**
   * 升级目标版本
   */
  private _toVersion: number = 1;
  /**
   * 升级 sql array
   */
  private _sqlArray: Array<string> = [];
  /**
   * 增加的表
   */
  private addTables: Array<string> = []
  private TAG = 'Migration'

  /**
   * dbName:数据库名称
   * table:表名称
   * fromVersion:数据库版本
   * */
  constructor(fromVersion: number, toVersion: number) {
    this._preVersion = fromVersion;
    this._toVersion = toVersion
  }

  /**
   * 新增列操作(需要新增的列名以及列数据类型名称,返回当前类实例)
   */
  addColumn(table: string, columnName: string, columnType: ColumnType, notNull = false, unique = false,
    defaultValue: undefined | string | number = undefined): Migration {
    let columnSql = `ALTER TABLE ${table} ADD ${columnName} ${columnType}`;
    if (unique) {
      columnSql = columnSql + ' UNIQUE '
    }
    if (notNull && defaultValue != undefined) {
      columnSql = columnSql + ' NOT NULL DEFAULT ' + defaultValue
    }
    this.sqlArray.push(columnSql)
    return this;
  }

  /**
   * 删除列操作(需要删除的列名,返回当前类实例)
   */
  deleteColumn(table: string, columnName: string): Migration {
    const deleteSql = `ALTER TABLE ${table} DROP COLUMN ${columnName}`
    this.sqlArray.push(deleteSql)
    return this;
  }


  /**
   * 新增表操作
   */
  addTable(table: string): Migration {
    this.addTables.push(table)
    return this;
  }

  /**
   * 删除表操作
   */
  deleteTable(table: string): Migration {
    const deleteSql = `DROP TABLE ${table}`;
    this.sqlArray.push(deleteSql)
    return this;
  }

  /**
   * 新增索引
   */
  addIndex(name: string, tableName: string, columnName: Array<string>, unique = false): Migration {
    let sql = ''
    if (unique) {
      sql = `CREATE UNIQUE INDEX IF NOT EXISTS ${name} ON ${tableName} (${columnName.join(', ')})`
    } else {
      sql = `CREATE INDEX IF NOT EXISTS ${name} ON ${tableName} (${columnName.join(', ')})`
    }
    this.sqlArray.push(sql)
    return this;
  }

  /**
   * 删除索引
   */
  deleteIndex(name: string, tableName: string): Migration {
    const sql = `DROP INDEX ${name}`;
    this.sqlArray.push(sql)
    return this;
  }

  /**
   * 增加数据库升级语句
   */
  addSql(sqlArray: Array<string>) {
    if (this._sqlArray) {
      this._sqlArray.push(...sqlArray)
    }
  }

  private get sqlArray() {
    return this._sqlArray
  }

  /**
   * 注意：调用后会触发 sql 生成，只在框架内调用
   * @returns
   */
  buildSql(): Array<string> {

    // 增加的表创建
    this.addTables.forEach(item => {
      const tableCls = DbStructInfo.getInstance().getTableCls(item)

      // 创建表
      const sql = SqlCompiler.getTableCreateSql(tableCls)
      this._sqlArray.push(sql)

      // 创建索引
      const index = SqlCompiler.getTableIndexSql(tableCls)
      this._sqlArray.push(...index)
    })
    return this._sqlArray
  }

  get preVersion() {
    return this._preVersion
  }

  get toVersion() {
    return this._toVersion
  }
}