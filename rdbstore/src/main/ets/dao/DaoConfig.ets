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

import { RdbError } from '../error/RdbError';
import { DbStructInfo } from '../model/relation/DbStructInfo';
import { Property } from '../model/relation/Property';
import { Rdb } from '../Rdb';
import { ClassConstructor } from '../util/ClassConstructor';

export class DaoConfig {
  public readonly tableName: string
  public readonly props: Property[]
  public readonly pkProps: Property[]
  public readonly allColumns: string[]
  public readonly pkColumns: string[]

  constructor(entityCls: ClassConstructor<Object>, dbStrcutInfo: DbStructInfo) {

    if (!dbStrcutInfo.getTableMeta(entityCls)) {
      throw new RdbError(Rdb.ErrorMsg.INIT_ERROR)
    }

    this.tableName = dbStrcutInfo.getTableMeta(entityCls)!.tableName
    this.props = dbStrcutInfo.getPropertyArray(entityCls)!
    this.pkProps = this.props.filter((item) => item.primaryKey)
    this.allColumns = this.props.map(prop => prop.columnName)
    this.pkColumns = this.pkProps.map(prop => prop.columnName)
  }
}
