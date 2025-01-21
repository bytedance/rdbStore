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
