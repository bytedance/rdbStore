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

import { RdbConst } from '../RdbConst';
import { ClassConstructor } from '../util/ClassConstructor';

export function Embedded<EmbeddedClass>(info: EmbeddedInfo<EmbeddedClass>): PropertyDecorator {
  return (target: object, propertyKey) => {
    const embeddedMeta: object = target[RdbConst.EMBEDDED] ?? new Object
    if ((typeof propertyKey === 'string')) {
      embeddedMeta[propertyKey] = info
    }
    target[RdbConst.EMBEDDED] = embeddedMeta
  };
}

/**
 * 嵌套信息
 */
export interface EmbeddedInfo<EmbeddedClass> {
  /**
   * 前缀，该前缀会自动增加在数据库列中作为列名，为嵌套类下避免列名重复语法糖
   * 若嵌套类中不存在重复的列名，则不使用即可
   */
  prefix?: string,
  /**
   * 嵌套的类型
   */
  targetClass: ClassConstructor<EmbeddedClass>
}

class InnerModel {
  name: string = ''
}

class Test {
  @Embedded({ prefix: '', targetClass: InnerModel })
  name: string = ''
}


