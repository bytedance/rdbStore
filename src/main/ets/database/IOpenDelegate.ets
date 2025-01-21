import { RdbDatabase } from './RdbDatabase'
import relationalStore  from '@ohos.data.relationalStore'

export interface IOpenDelegate {
  onConfig(database: RdbDatabase, version: number): Promise<boolean>

  onDowngrade(db: relationalStore.RdbStore, database: RdbDatabase): Promise<boolean>

  onUpgrade(db: relationalStore.RdbStore, database: RdbDatabase, version: number, newVersion: number): Promise<boolean>

  onCreate(db: relationalStore.RdbStore, database: RdbDatabase): Promise<boolean>
}