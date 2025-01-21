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

/**
 * 数据库列类型
 * 注意：大数则使用 text 类型，或者使用 convertor 转换参考：BigIntToStringConvertor
 */
export enum ColumnType {
  /**
   * 字符串
   */
  TEXT = 'TEXT',
  /**
   * 整型 范围： ±2147483647
   */
  INTEGER = 'INTEGER',
  /**
   * 浮点数
   */
  REAL = 'REAL',
  /**
   * 二进制对象
   */
  BLOB = 'BLOB'
}