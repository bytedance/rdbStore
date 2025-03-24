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

import { RdbDatabase } from './RdbDatabase'
import relationalStore  from '@ohos.data.relationalStore'

export interface IOpenDelegate {

  /**
   * 数据库配置阶段: 完成装饰器解析生成表结构信息
   * @param database
   * @param version
   * @returns
   */
  onConfig(database: RdbDatabase, version: number): Promise<boolean>

  /**
   * 数据库创建时发生降级操作
   * @param db
   * @param database
   * @returns
   */
  onDowngrade(db: relationalStore.RdbStore, database: RdbDatabase): Promise<boolean>

  /**
   * 数据库升级回调
   * @param db
   * @param database
   * @param version
   * @param newVersion
   * @returns
   */
  onUpgrade(db: relationalStore.RdbStore, database: RdbDatabase, version: number, newVersion: number): Promise<boolean>

  /**
   * 数据库创建回调：创建 db 文件，注意区分数据库打开
   * @param db
   * @param database
   * @returns
   */
  onCreate(db: relationalStore.RdbStore, database: RdbDatabase): Promise<boolean>

  /**
   * 数据库打开回调
   * @param database
   * @returns
   */
  onOpen(database: RdbDatabase): Promise<boolean>
}