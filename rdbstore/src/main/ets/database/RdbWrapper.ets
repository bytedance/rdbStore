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

import relationalStore from '@ohos.data.relationalStore'
import { AsyncCallback } from '@kit.BasicServicesKit'
import { Extension } from '../extension/Extension'
import { RdbMonitor } from '../util/RdbMonitor'

/**
 * 封装所有涉及使用原始 db 进行的操作
 */
export class RdbWrapper {
  private readonly dbImpl: relationalStore.RdbStore
  private readonly monitor: RdbMonitor
  private readonly extension: Extension

  constructor(db: relationalStore.RdbStore, monitor: RdbMonitor, extension: Extension) {
    this.dbImpl = db
    this.monitor = monitor
    this.extension = extension
  }

  beginTransaction() {
    return this.dbImpl.beginTransaction()
  }

  commit() {
    return this.dbImpl.commit()
  }

  rollBack() {
    return this.dbImpl.rollBack()
  }

  backup(destName: string, callback: AsyncCallback<void>): void {
    return this.dbImpl.backup(destName, callback)
  }

  restore(srcName: string, callback: AsyncCallback<void>): void {
    return this.dbImpl.restore(srcName, callback)
  }

  close(): Promise<void> {
    return this.dbImpl.close()
  }

  async getModifyTime(table: string, columnName: string,
    primaryKeys: relationalStore.PRIKeyType[]): Promise<relationalStore.ModifyTime> {
    return await this.dbImpl.getModifyTime(table, columnName, primaryKeys)
  }

  getVersion(): number {
    return this.dbImpl.version
  }

  async update(values: relationalStore.ValuesBucket, predicates: relationalStore.RdbPredicates,
    conflict: relationalStore.ConflictResolution): Promise<number> {
    return await this.dbImpl.update(values, predicates, conflict)
  }

  updateSync(values: relationalStore.ValuesBucket, predicates: relationalStore.RdbPredicates,
    conflict?: relationalStore.ConflictResolution): number {
    return this.dbImpl.updateSync(values, predicates, conflict)
  }

  async delete(predicates: relationalStore.RdbPredicates): Promise<number> {
    return await this.dbImpl.delete(predicates)
  }

  deleteSync(predicates: relationalStore.RdbPredicates): number {
    return this.dbImpl.deleteSync(predicates)
  }

  async insert(table: string, values: relationalStore.ValuesBucket,
    conflict: relationalStore.ConflictResolution): Promise<number> {
    return await this.dbImpl.insert(table, values, conflict)
  }

  async batchInsert(table: string, values: Array<relationalStore.ValuesBucket>): Promise<number> {
    return await this.dbImpl.batchInsert(table, values)
  }

  insertSync(table: string, values: relationalStore.ValuesBucket,
    conflict: relationalStore.ConflictResolution): number {
    return this.dbImpl.insertSync(table, values, conflict)
  }

  async query(predicates: relationalStore.RdbPredicates, columns?: Array<string>,
    desc: string = 'predicates', tableName?: string): Promise<relationalStore.ResultSet> {
    const startTime = Date.now()
    const result = await this.dbImpl.query(predicates, columns)
    this.monitor.eventQuery(desc, startTime, tableName)
    return result
  }

  querySync(predicates: relationalStore.RdbPredicates, columns?: Array<string>): relationalStore.ResultSet {
    return this.dbImpl.querySync(predicates, columns)
  }

  async querySql(sql: string, bindArgs?: Array<relationalStore.ValueType>, table?: string): Promise<relationalStore.ResultSet> {
    const startTime = Date.now()
    const result = await this.dbImpl.querySql(sql, bindArgs)
    this.monitor.eventQuery(sql, startTime, table)
    return result
  }

  querySqlSync(sql: string, bindArgs?: Array<relationalStore.ValueType>, table?: string): relationalStore.ResultSet {
    const startTime = Date.now()
    const result = this.dbImpl.querySqlSync(sql, bindArgs)
    this.monitor.eventQuery(sql, startTime, table)
    return result
  }

  async execute(sql: string, args?: Array<relationalStore.ValueType>, table?: string): Promise<relationalStore.ValueType> {
    const startTime = Date.now()
    const result = await this.dbImpl.execute(sql, args)
    this.monitor.eventQuery(sql, startTime, table)
    return result
  }

  async executeSql(sql: string, bindArgs?: Array<relationalStore.ValueType>, table?: string): Promise<void> {
    const startTime = Date.now()
    const result = await this.dbImpl.executeSql(sql, bindArgs)
    this.monitor.eventQuery(sql, startTime, table)
    return result
  }

  executeSync(sql: string, args?: Array<relationalStore.ValueType>, table?: string): relationalStore.ValueType {
    const startTime = Date.now()
    const result = this.dbImpl.executeSync(sql, args)
    this.monitor.eventQuery(sql, startTime, table)
    return result
  }
}