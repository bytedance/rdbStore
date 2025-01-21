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

import { RdbError } from '../../error/RdbError'
import { Rdb } from '../../Rdb'
import { ClassConstructor } from '../../util/ClassConstructor'
import { Property } from './Property'
import { TableMetaInfo } from './TableMetaInfo'


/**
 * db 结构信息
 */
export class DbStructInfo {
  /**
   * 业务 model 和 property 映射
   */
  readonly propertyMap: Map<ClassConstructor<Object>, Map<string, Property>> = new Map
  /**
   * db 和 表 映射
   */
  readonly entityMap: Map<string, Array<ClassConstructor<Object>>> = new Map
  /**
   * table name 和 业务 model
   */
  readonly tableMap: Map<ClassConstructor<Object>, TableMetaInfo> = new Map

  private constructor() {
  }

  private static instance: DbStructInfo

  static getInstance(): DbStructInfo {
    if (!DbStructInfo.instance) {
      DbStructInfo.instance = new DbStructInfo()
    }
    return DbStructInfo.instance
  }

  addProperty(entity: ClassConstructor<Object>, property: Property) {
    let props = this.propertyMap.get(entity)
    if (!props) {
      props = new Map
      this.propertyMap.set(entity, props)
    }

    let key = property.name

    // 嵌套场景，key 设置为列名，避免嵌套场景，里外层同名字段重复
    if (property.isEmbedded()) {
      key = property.columnName
    }

    props.set(key, property)
  }

  addEntity(dbName: string, ...entityArray: Array<ClassConstructor<Object>>) {
    let entities = this.entityMap.get(dbName)
    if (!entities) {
      entities = new Array
      this.entityMap.set(dbName, entities)
    }
    entityArray.forEach(item => {
      if (entities!.indexOf(item) < 0) {
        entities!.push(item)
      }
    })
  }

  addTable(entity: ClassConstructor<Object>, tableMeta: TableMetaInfo) {
    this.tableMap.set(entity, tableMeta)
  }

  getTableCls(tableName: string): ClassConstructor<Object> {
    let cls: ClassConstructor<Object> | undefined = undefined
    this.tableMap.forEach((value, key) => {
      if (value.tableName === tableName) {
        cls = key
      }
    })
    if (!cls) {
      throw new RdbError(Rdb.ErrorMsg.INIT_ERROR)
    }
    return cls
  }

  getTableMeta(entity: ClassConstructor<Object>): TableMetaInfo | undefined {
    return this.tableMap.get(entity)
  }

  getTableMetaByName(tableName: string): TableMetaInfo | undefined {
    return this.getTableMeta(this.getTableCls(tableName))
  }

  getEntites(dbName: string): Array<ClassConstructor<Object>> | undefined {
    return this.entityMap.get(dbName)
  }

  getProperties(entity: ClassConstructor<Object>): IterableIterator<Property> | undefined {
    return this.propertyMap.get(entity)?.values()
  }

  getPropsByName(tableName: string): Array<Property> {
    return this.getPropertyArray(this.getTableCls(tableName)) ?? new Array
  }

  getPropertyArray(entity: ClassConstructor<Object>): Array<Property> | undefined {
    if (this.propertyMap.get(entity)?.values()) {
      return Array.from(this.propertyMap.get(entity)!.values())
    }
    return undefined
  }

  /**
   * 深度为 1 叶子节点直接传 property name
   * 深度 > 1 传 column name （嵌套层级下使用 name 可能存在重名字的情况，column name 保证唯一性）
   * @param entity
   * @param key
   * @returns
   */
  getProperty(entity: ClassConstructor<Object>, key: string) {
    return this.propertyMap.get(entity)?.get(key)
  }

  /**
   * 检查 db 结构信息是否已经生成
   */
  getDbStructInfoReady(dbName: string): boolean {
    if (this.entityMap.get(dbName)) {
      return this.entityMap.get(dbName)!.length > 0
    }
    return false
  }
}
