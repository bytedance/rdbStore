import { IOpenDelegate } from '../database/IOpenDelegate'
import { RdbConfig } from '../database/RdbConfig'
import { IEventSender } from './IEventSender'
import { ILog } from './ILog'
import { TuneDbParamPlugin } from './TuneDbParamPlugin'

/**
 * 数据库能力组件集
 */
export class Extension {
  /**
   * db config
   */
  config: RdbConfig
  /**
   * 日志组件
   */
  log?: ILog
  /**
   * 埋点上报组件
   */
  eventSender?: IEventSender
  /**
   * db open helper
   */
  openListener?: IOpenDelegate
  /**
   * db param opt
   */
  tuneDbParamOptPlugin?: TuneDbParamPlugin

  constructor(config: RdbConfig) {
    this.config = config
  }
}