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