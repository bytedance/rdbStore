import { DiffItem } from '../../database/auto/DiffUtil'
import { ClassConstructor } from '../../util/ClassConstructor'
import { IndexMetaInfo } from './IndexMetaInfo'

export class TableMetaInfo implements DiffItem {
  key(): string {
    return this.tableName
  }

  tableName: string = ''
  entityCls: ClassConstructor<Object> = Object
  index: Array<IndexMetaInfo> = new Array
}