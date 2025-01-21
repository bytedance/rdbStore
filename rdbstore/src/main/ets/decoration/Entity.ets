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

import { PropertyConverter } from '../model/relation/converter/ConvertParameter';
import { RdbConst } from '../RdbConst';

/**
 * 表注解
 * @param tableInfo
 * @returns
 */
export function Entity(tableInfo: TableInfo): ClassDecorator {
  return (target: object) => {
    target[RdbConst.TABLE] = tableInfo
  };
}

/**
 * 表信息
 */
export interface TableInfo {
  /**
   * 表名
   */
  tableName: string
  /**
   * 索引信息
   */
  index?: Array<IndexInfo>
}

/**
 * 索引信息
 */
export interface IndexInfo {

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
}


class PropertyConverterTest extends PropertyConverter<bigint, string> {
  convertToEntityProperty(databaseValue: string): bigint {
    return BigInt(databaseValue)
  }

  convertToDatabaseValue(entityProperty: bigint): string {
    return entityProperty.toString()
  }
}