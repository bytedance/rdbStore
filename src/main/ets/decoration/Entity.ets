import { PropertyConverter } from '../model/relation/converter/ConvertParameter';
import { RdbConst } from '../RdbConst';

/**
 * 表注解
 * @param tableInfo
 * @returns
 */
export function Entity(tableInfo: TableInfo): ClassDecorator {
  return (target: object) => {
    target[RdbConst.TABLE] = tableInfo
  };
}

/**
 * 表信息
 */
export interface TableInfo {
  /**
   * 表名
   */
  tableName: string
  /**
   * 索引信息
   */
  index?: Array<IndexInfo>
}

/**
 * 索引信息
 */
export interface IndexInfo {

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
}


class PropertyConverterTest extends PropertyConverter<bigint, string> {
  convertToEntityProperty(databaseValue: string): bigint {
    return BigInt(databaseValue)
  }

  convertToDatabaseValue(entityProperty: bigint): string {
    return entityProperty.toString()
  }
}