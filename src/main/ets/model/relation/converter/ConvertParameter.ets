import { ClassConstructor } from '../../../util/ClassConstructor';

/**
 * convert 类型列处理
 */
export class ConvertParameter {
  private converter: ClassConstructor<PropertyConverter<Object, Object>>
  private columnType: string

  constructor(converter: ClassConstructor<PropertyConverter<Object, Object>>, columnType: string) {
    this.converter = converter;
    this.columnType = columnType;
  }

  getConverter(): ClassConstructor<PropertyConverter<Object, Object>> {
    return this.converter;
  }

  getColumnType(): string {
    return this.columnType;
  }
}

export abstract class PropertyConverter<ModelValue, DbValue> {
  abstract convertToEntityProperty(databaseValue: DbValue): ModelValue;

  abstract convertToDatabaseValue(entityProperty: ModelValue): DbValue;
}