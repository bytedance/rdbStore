import { DiffOps, DiffType } from './DiffOps'

/**
 * 保存计算出的 diff 结果
 */
export class DiffResult<DATA> {
  op: DiffOps
  diffType: DiffType
  data: DATA

  constructor(op: DiffOps, diffType: DiffType, data: DATA) {
    this.op = op
    this.diffType = diffType
    this.data = data
  }
}