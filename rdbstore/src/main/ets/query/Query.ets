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

import { PredicatesBuilder } from './PredicatesBuilder';
import relationalStore from '@ohos.data.relationalStore';
import { RdbDao } from '../dao/RdbDao';

/**
 * 构建 db 查询 query
 */
export class Query<Entity extends object> {
  private readonly tag = 'query'
  private readonly predicates: relationalStore.RdbPredicates
  private readonly _predicateDesc: string
  private readonly dao: RdbDao<Entity>

  constructor(builder: PredicatesBuilder<Entity>) {
    this.predicates = builder.predicates
    this.dao = builder.dao
    this._predicateDesc = builder.predicatesDesc
  }

  run(): Promise<Array<Entity>> {
    this.dao.database.extension.log?.d(this.tag, `query run: table: ${this.dao.config.tableName} do query predicates: ${this._predicateDesc}`)
    return this.dao.queryPredicate(this.predicates, this._predicateDesc)
  }

  /**
   * 谓词描述
   * @returns
   */
  get predicatesDesc() {
    return this._predicateDesc
  }
}