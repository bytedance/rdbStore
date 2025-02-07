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
import { ClassConstructor } from '../util/ClassConstructor';
import { ColumnType } from './ColumnType';

/**
 * 列注解处理
 * @param v
 * @returns
 */
export function Columns(info: ColumnInfo): PropertyDecorator {
  return (target: object, propertyKey) => {
    const columnMeta: object = target[RdbConst.COLUMN] ?? new Object
    if ((typeof propertyKey === 'string')) {
      columnMeta[propertyKey] = info
    }
    target[RdbConst.COLUMN] = columnMeta
  };
}

/**
 * 列信息
 */
export interface ColumnInfo {
  /**
   * 列名
   */
  name: string
  /**
   * 列类型
   */
  type: ColumnType
  /**
   * 是否是主键
   */
  isPrimaryKey?: boolean
  /**
   * 是否自增
   */
  autoincrement?: boolean
  /**
   * 唯一性约束：是否唯一，插入等会进行校验
   */
  unique?: boolean
  /**
   * 非空约束
   */
  notNull?: boolean
  /**
   * 类型转换器，业务类型 <> Db 类型
   */
  convertor?: ClassConstructor<PropertyConverter<Object, Object>>
}

/**
 * model string, 存储按 integer 存储
 */
export class BigIntStrConvertor extends PropertyConverter<string, bigint> {
  convertToEntityProperty(databaseValue: bigint): string {
    return databaseValue.toString();
  }

  convertToDatabaseValue(entityProperty: string): bigint {
    return BigInt(entityProperty)
  }
}

/**
 * model number, 存储按 string 存储
 */
export class NumToStringConvertor extends PropertyConverter<number, string> {
  convertToEntityProperty(databaseValue: string): number {
    return Number(databaseValue);
  }

  convertToDatabaseValue(entityProperty: number): string {
    return entityProperty.toString()
  }
}

/**
 * model bigint, 存储按 string 存储
 */
export class BigIntToStringConvertor extends PropertyConverter<bigint, string> {
  convertToEntityProperty(databaseValue: string): bigint {
    return BigInt(databaseValue);
  }

  convertToDatabaseValue(entityProperty: bigint): string {
    return entityProperty.toString()
  }
}

/**
 * model bigint, 存储按 integer 存储
 */
export class BigIntConvertor extends PropertyConverter<bigint, bigint> {
  convertToEntityProperty(databaseValue: bigint): bigint {
    return BigInt(databaseValue);
  }

  convertToDatabaseValue(entityProperty: bigint): bigint {
    return entityProperty
  }
}