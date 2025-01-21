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

import { Columns } from './Column';
import { ColumnType } from './ColumnType';
import { Entity } from './Entity';

@Entity({ tableName: 'SampleEntity', index: [{ name: 'idIndex', columnName: ['order_id', 'group_id'] }] })
export class SampleEntity {
  @Columns({
    name: 'id',
    type: ColumnType.INTEGER,
    autoincrement: true,
    isPrimaryKey: true
  })
  id: number | null = null;
  /**
   * orderID
   */
  @Columns({ name: 'order_id', type: ColumnType.INTEGER, })
  orderID: number = -1
  /**
   * 每个数据单独的 group_id
   */
  @Columns({ name: 'group_id', type: ColumnType.TEXT })
  groupID: string = ""
  /**
   * 原始数据
   */
  @Columns({ name: 'raw_data', type: ColumnType.TEXT })
  rawData: string = ""
  /**
   * 置顶标识
   */
  @Columns({ name: 'stick_style', type: ColumnType.INTEGER })
  stickStyle: number = 0
  /**
   * channel id
   */
  @Columns({ name: 'channel', type: ColumnType.TEXT })
  channel: string = ''
  /**
   * read_time
   */
  @Columns({ name: 'read_time', type: ColumnType.INTEGER })
  readTime: number = 0
  /**
   * user_id
   */
  @Columns({ name: 'user_id', type: ColumnType.INTEGER })
  userId: number = 0
}
