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
import { ClassConstructor } from '../util/ClassConstructor'
import { Migration } from './migration/Migration'

/**
 * db config
 */
export interface RdbConfig {
  /**
   * 数据库版本
   */
  version: number
  /**
   * 数据库名
   */
  dbName: string
  /**
   * 数据库中所有 Entity 表
   */
  entities: ClassConstructor<Object>[]
  /**
   * 所有管理升级迁移信息
   */
  migrations: Migration[]
  /**
   * 是否加密
   */
  encrypt: boolean
  /**
   * 多设备分布式协同才需要考虑安全等级
   */
  securityLevel: relationalStore.SecurityLevel
  /**
   * 是否自动升级，默认关闭，配置自动升级后不再需要设置 migration，可以自动根据表、列信息的 diff 来进行自动化升级
   * @returns
   */
  autoMigrate: boolean
  /**
   * 从某个版本开始废弃低版本数据库，重新创建
   * 比如配置：5，会删除数据库版本为 1 2 3 4 这些版本数据库
   */
  deprecatedFromVersion?: number
}