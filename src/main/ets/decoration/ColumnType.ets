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