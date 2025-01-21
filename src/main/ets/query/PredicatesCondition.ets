import relationalStore from '@ohos.data.relationalStore';
import { Op } from './Op';

/**
 * 通过列属性来便捷操作 db
 */
export class PredicatesCondition {
  op: Op
  columnName: string
  values: Array<relationalStore.ValueType>

  constructor(op: Op, columnName: string, ...values: Array<relationalStore.ValueType>) {
    this.op = op
    this.columnName = columnName
    this.values = values
  }
}