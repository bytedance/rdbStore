import { RdbError } from '../error/RdbError';
import { DbStructInfo } from '../model/relation/DbStructInfo';
import { Property } from '../model/relation/Property';
import { Rdb } from '../Rdb';
import { ClassConstructor } from '../util/ClassConstructor';

export class DaoConfig {
  public readonly tableName: string
  public readonly props: Property[]
  public readonly pkProps: Property[]
  public readonly allColumns: string[]
  public readonly pkColumns: string[]

  constructor(entityCls: ClassConstructor<Object>, dbStrcutInfo: DbStructInfo) {

    if (!dbStrcutInfo.getTableMeta(entityCls)) {
      throw new RdbError(Rdb.ErrorMsg.INIT_ERROR)
    }

    this.tableName = dbStrcutInfo.getTableMeta(entityCls)!.tableName
    this.props = dbStrcutInfo.getPropertyArray(entityCls)!
    this.pkProps = this.props.filter((item) => item.primaryKey)
    this.allColumns = this.props.map(prop => prop.columnName)
    this.pkColumns = this.pkProps.map(prop => prop.columnName)
  }
}
