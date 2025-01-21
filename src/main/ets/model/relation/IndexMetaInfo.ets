import { DiffItem } from '../../database/auto/DiffUtil'

/**
 * 索引信息
 */
export class IndexMetaInfo implements DiffItem {
  /**
   * 索引名
   */
  name: string
  /**
   * 建索引列
   */
  columnName: Array<string>
  /**
   * 是否唯一性索引，唯一性索引：保证索引的列各种操作的唯一性，插入会检查保证唯一性
   */
  unique?: boolean

  constructor(name: string, columnName: Array<string>, unique: boolean = false) {
    this.name = name
    this.columnName = columnName
    this.unique = unique
  }

  key(): string {
    return this.name
  }
}