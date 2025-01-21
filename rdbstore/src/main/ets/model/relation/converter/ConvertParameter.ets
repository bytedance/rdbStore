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