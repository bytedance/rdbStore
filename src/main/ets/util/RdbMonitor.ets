import { RdbDatabase } from '../database/RdbDatabase';
import { EventConstants } from '../EventConstant';
import { Extension } from '../extension/Extension';
import { EventParamsBaseType } from '../extension/IEventSender';
import { Rdb } from '../Rdb';

/**
 * 监控组件
 */
export class RdbMonitor {
  private readonly extension: Extension

  constructor(extension: Extension) {
    this.extension = extension
  }

  /**
   * 初始化耗时
   * @param startTime
   */
  eventInit(startTime: number) {
    const param: Record<string, EventParamsBaseType> = {}
    param[EventConstants.SCENE_NAME] = EventConstants.INIT_SCENE
    param[EventConstants.DURATION] = Date.now() - startTime
    param[EventConstants.DB_NAME] = this.extension.config.dbName
    this.extension.log?.i(EventConstants.RDB_MONITOR, JSON.stringify(param))
    this.extension.eventSender?.send(EventConstants.RDB_MONITOR, param)
  }

  /**
   * 上报表大小
   */
  async eventTableSize(database: RdbDatabase) {
    const param: Record<string, EventParamsBaseType> = {}
    for (const element of database.allDao) {
      param[EventConstants.SCENE_NAME] = EventConstants.TABLE_SIZE_SCENE
      param[EventConstants.TABLE_NAME] = element.config.tableName
      param['size'] = await element.getCount()
      this.extension.eventSender?.send(EventConstants.RDB_MONITOR, param)
    }
  }

  /**
   * 上报查询耗时
   * @param startTime
   */
  eventQuery(sql: string, startTime: number, table: string = '') {
    const param: Record<string, EventParamsBaseType> = {}
    param[EventConstants.SCENE_NAME] = EventConstants.QUERY_SCENE
    param[EventConstants.DURATION] = Date.now() - startTime
    param[EventConstants.DB_NAME] = this.extension.config.dbName
    param[EventConstants.TABLE_NAME] = table
    param[EventConstants.SQL] = this.removeBetweenSelectAndFrom(sql)
    this.extension.log?.i(EventConstants.RDB_MONITOR, JSON.stringify(param))
    this.extension.eventSender?.send(EventConstants.RDB_MONITOR, param)
  }

  /**
   * 去 sql 中列信息，只保留谓词部分
   * @param sqlQuery
   * @returns
   */
  removeBetweenSelectAndFrom(sqlQuery: string): string {
    const parts = sqlQuery.toUpperCase().split(/(SELECT|FROM)/);
    let newQuery = '';

    for (let i = 0; i < parts.length; i++) {
      if (parts[i] === 'SELECT') {
        newQuery += parts[i] + ' ';
        i++;
        while (parts[i] !== 'FROM') {
          i++;
        }
        newQuery += 'FROM ';
      } else {
        newQuery += parts[i] + ' ';
      }
    }

    return newQuery.trim();
  }

  /**
   * 上报数据库异常
   */
  reportError(msg: Rdb.ErrorMsg, err: Error) {
    const param: Record<string, EventParamsBaseType> = {}
    param[EventConstants.SCENE_NAME] = EventConstants.ERROR_SCENE
    param[EventConstants.ERROR_NAME] = err.name
    param[EventConstants.ERROR_MSG] = `${msg.toString()} detail: ${err.message}`
    this.extension.log?.i(EventConstants.RDB_MONITOR, JSON.stringify(param))
    this.extension.eventSender?.send(EventConstants.RDB_MONITOR, param)
  }
}