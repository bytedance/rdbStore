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