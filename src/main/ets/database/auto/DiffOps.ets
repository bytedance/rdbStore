/**
 * diff 结果类型
 */
export enum DiffOps {
  ADD = 'add',
  DELETE = 'delete'
}

/**
 * diff 类型
 */
export enum DiffType {
  COLUMN = 'column',
  TABLE = 'table',
  INDEX = 'index'
}