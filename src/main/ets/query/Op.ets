/**
 * 数据库查询谓词
 */
export enum Op {
  /**
   * 和列相关的谓词
   */
  equalTo = 'equalTo',
  notEqualTo = 'notEqualTo',
  contains = 'contains',
  beginsWith = 'beginsWith',
  endsWith = 'endsWith',
  isNull = 'isNull',
  isNotNull = 'isNotNull',
  like = 'like',
  glob = 'glob',
  between = 'between',
  notBetween = 'notBetween',
  greaterThan = 'greaterThan',
  lessThan = 'lessThan',
  greaterThanOrEqualTo = 'greaterThanOrEqualTo',
  lessThanOrEqualTo = 'lessThanOrEqualTo',
  orderByAsc = 'orderByAsc',
  orderByDesc = 'orderByDesc',
  inOp = 'inOp',
  notInOp = 'notInOp',
  notContains = 'notContains',
  notLike = 'notLike',
  beginWrap = 'beginWrap',
  endWrap = 'endWrap',
  and = 'and',
  or = 'or',

  /**
   * 和列无关的谓词
   */
  distinct = 'distinct',
  limitAs = 'limitAs',
  offsetAs = 'offsetAs'
}