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

import { DiffItem } from '../../database/auto/DiffUtil'

/**
 * 索引信息
 */
export class IndexMetaInfo implements DiffItem {
  /**
   * 索引名
   */
  name: string
  /**
   * 建索引列
   */
  columnName: Array<string>
  /**
   * 是否唯一性索引，唯一性索引：保证索引的列各种操作的唯一性，插入会检查保证唯一性
   */
  unique?: boolean

  constructor(name: string, columnName: Array<string>, unique: boolean = false) {
    this.name = name
    this.columnName = columnName
    this.unique = unique
  }

  key(): string {
    return this.name
  }
}