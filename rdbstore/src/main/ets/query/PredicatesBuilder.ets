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

import { RdbDao } from '../dao/RdbDao'
import { PredicatesCondition } from './PredicatesCondition'
import { Query } from './Query'
import relationalStore from '@ohos.data.relationalStore'
import { Op } from './Op'
import { Property } from '../model/relation/Property'

/**
 * 通过 builder 构建查询
 * 组织查询谓词
 */
export class PredicatesBuilder<ENTITY extends object> {
  private readonly _predicates: relationalStore.RdbPredicates
  private _predicatesDesc: string = ''
  private readonly _dao: RdbDao<ENTITY>

  constructor(dao: RdbDao<ENTITY>) {
    this._predicates = dao.getPredicates()
    this._dao = dao
  }

  where(...conditions: Array<PredicatesCondition>): PredicatesBuilder<ENTITY> {
    this.conditionToPredicates(conditions)
    return this
  }

  and(...conditions: Array<PredicatesCondition>): Array<PredicatesCondition> {

    const result: Array<PredicatesCondition> = new Array

    result.push(this.beginWrap())

    let jump = false
    conditions.forEach((item, index) => {
      result.push(item)

      if (item.op === Op.beginWrap) {
        jump = true
      }

      if (item.op === Op.endWrap) {
        jump = false
      }

      if (jump) {
        return
      }

      let next: PredicatesCondition | undefined = undefined

      if ((index + 1) != conditions.length) {
        next = conditions[index + 1]
      }

      if (item.op !== Op.beginWrap && next && next.op !== Op.endWrap) {
        result.push(new PredicatesCondition(Op.and, ''))
      }

    })

    result.push(this.endWrap())

    return result
  }

  or(...conditions: Array<PredicatesCondition>): Array<PredicatesCondition> {

    const result: Array<PredicatesCondition> = new Array

    result.push(this.beginWrap())

    let jump = false
    conditions.forEach((item, index) => {
      result.push(item)

      if (item.op === Op.beginWrap) {
        jump = true
      }

      if (item.op === Op.endWrap) {
        jump = false
      }

      if (jump) {
        return
      }

      let next: PredicatesCondition | undefined = undefined

      if ((index + 1) != conditions.length) {
        next = conditions[index + 1]
      }

      if (item.op !== Op.beginWrap && next && next.op !== Op.endWrap) {
        result.push(new PredicatesCondition(Op.or, ''))
      }

    })

    result.push(this.endWrap())

    return result
  }

  private beginWrap(): PredicatesCondition {
    return new PredicatesCondition(Op.beginWrap, '')
  }

  private endWrap(): PredicatesCondition {
    return new PredicatesCondition(Op.endWrap, '')
  }

  distinct(): PredicatesBuilder<ENTITY> {
    this._predicates.distinct()
    this._predicatesDesc = this._predicatesDesc + ' distinct '
    return this
  }

  limit(num: number): PredicatesBuilder<ENTITY> {
    this._predicatesDesc = this._predicatesDesc + `limit: ${num}`
    this._predicates.limitAs(num)
    return this
  }

  fromIndex(num: number): PredicatesBuilder<ENTITY> {
    this._predicatesDesc = this._predicatesDesc + `fromIndex: ${num}`
    this._predicates.offsetAs(num)
    return this
  }

  orderByAsc(prop: Property): PredicatesBuilder<ENTITY> {
    this._predicatesDesc = this._predicatesDesc + `orderByAsc: ${prop.columnName}`
    this._predicates.orderByAsc(prop.columnName)
    return this
  }

  orderByDesc(prop: Property): PredicatesBuilder<ENTITY> {
    this._predicatesDesc = this._predicatesDesc + `orderByAsc: ${prop.columnName}`
    this._predicates.orderByDesc(prop.columnName)
    return this
  }

  build(): Query<ENTITY> {
    const query = new Query(this)
    return query
  }

  private conditionToPredicates(conditions: Array<PredicatesCondition>) {
    conditions.forEach(item => {
      switch (item.op) {
        case Op.equalTo:
          this._predicatesDesc = this._predicatesDesc + `column: ${item.columnName} equalTo: ${item.values[0]} `
          this._predicates.equalTo(item.columnName, item.values[0])
          break;
        case Op.notEqualTo:
          this._predicatesDesc = this._predicatesDesc + `column: ${item.columnName}  notEqualTo: ${item.values[0]} `
          this._predicates.notEqualTo(item.columnName, item.values[0])
          break;
        case Op.contains:
          this._predicatesDesc = this._predicatesDesc + `column: ${item.columnName}  contains: ${item.values[0]} `
          this._predicates.contains(item.columnName, item.values[0] as string)
          break;
        case Op.beginsWith:
          this._predicatesDesc = this._predicatesDesc + `column: ${item.columnName}  beginsWith: ${item.values[0]} `
          this._predicates.beginsWith(item.columnName, item.values[0] as string)
          break;
        case Op.endsWith:
          this._predicatesDesc = this._predicatesDesc + `column: ${item.columnName}  endsWith: ${item.values[0]} `
          this._predicates.endsWith(item.columnName, item.values[0] as string)
          break;
        case Op.isNull:
          this._predicatesDesc = this._predicatesDesc + `column: ${item.columnName}  isNull `
          this._predicates.isNull(item.columnName)
          break;
        case Op.isNotNull:
          this._predicatesDesc = this._predicatesDesc + `column: ${item.columnName}  isNotNull `
          this._predicates.isNotNull(item.columnName)
          break;
        case Op.like:
          this._predicatesDesc = this._predicatesDesc + `column: ${item.columnName}  like: ${item.values[0]} `
          this._predicates.like(item.columnName, item.values[0] as string)
          break;
        case Op.glob:
          this._predicatesDesc = this._predicatesDesc + `column: ${item.columnName}  glob: ${item.values[0]} `
          this._predicates.glob(item.columnName, item.values[0] as string)
          break;
        case Op.between:
          this._predicatesDesc =
            this._predicatesDesc + `column: ${item.columnName}  between: ${item.values[0]} ~ ${item.values[1]} `
          this._predicates.between(item.columnName, item.values[0], item.values[1])
          break;
        case Op.notBetween:
          this._predicatesDesc =
            this._predicatesDesc + `column: ${item.columnName}  notBetween: ${item.values[0]} ~ ${item.values[1]} `
          this._predicates.notBetween(item.columnName, item.values[0], item.values[1])
          break;
        case Op.greaterThan:
          this._predicatesDesc = this._predicatesDesc + `column: ${item.columnName}  greaterThan: ${item.values[0]} `
          this._predicates.greaterThan(item.columnName, item.values[0])
          break;
        case Op.lessThan:
          this._predicatesDesc = this._predicatesDesc + `column: ${item.columnName}  lessThan: ${item.values[0]} `
          this._predicates.lessThan(item.columnName, item.values[0])
          break;
        case Op.greaterThanOrEqualTo:
          this._predicatesDesc =
            this._predicatesDesc + `column: ${item.columnName}  greaterThanOrEqualTo: ${item.values[0]} `
          this._predicates.greaterThanOrEqualTo(item.columnName, item.values[0])
          break;
        case Op.lessThanOrEqualTo:
          this._predicatesDesc =
            this._predicatesDesc + `column: ${item.columnName}  lessThanOrEqualTo: ${item.values[0]} `
          this._predicates.lessThanOrEqualTo(item.columnName, item.values[0])
          break;
        case Op.orderByAsc:
          this._predicatesDesc = this._predicatesDesc + `column: ${item.columnName}  orderByAsc `
          this._predicates.orderByAsc(item.columnName)
          break;
        case Op.orderByDesc:
          this._predicatesDesc = this._predicatesDesc + `column: ${item.columnName}  orderByDesc:  `
          this._predicates.orderByDesc(item.columnName)
          break;
        case Op.inOp:
          this._predicatesDesc =
            this._predicatesDesc + `column: ${item.columnName}  inOp: ${JSON.stringify(item.values)} `
          this._predicates.in(item.columnName, item.values)
          break;
        case Op.notInOp:
          this._predicatesDesc =
            this._predicatesDesc + `column: ${item.columnName}  notInOp: ${JSON.stringify(item.values)} `
          this._predicates.notIn(item.columnName, item.values)
          break;
        case Op.notContains:
          this._predicatesDesc = this._predicatesDesc + `column: ${item.columnName}  notContains: ${item.values[0]} `
          this._predicates.notContains(item.columnName, item.values[0] as string)
          break;
        case Op.notLike:
          this._predicatesDesc = this._predicatesDesc + `column: ${item.columnName}  notLike: ${item.values[0]} `
          this._predicates.notLike(item.columnName, item.values[0] as string)
          break;
        case Op.beginWrap:
          this._predicatesDesc = this._predicatesDesc + ` ( `
          this._predicates.beginWrap()
          break;
        case Op.endWrap:
          this._predicatesDesc = this._predicatesDesc + ` ) `
          this._predicates.endWrap()
          break;
        case Op.and:
          this._predicatesDesc = this._predicatesDesc + ` and `
          this._predicates.and()
          break;
        case Op.or:
          this._predicatesDesc = this._predicatesDesc + ` or `
          this._predicates.or()
          break;
        default:
          break;
      }
    })
  }

  get predicates() {
    return this._predicates
  }

  get dao() {
    return this._dao
  }

  get predicatesDesc() {
    return this._predicatesDesc
  }
}