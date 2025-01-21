import { Extension } from '../extension/Extension';
import { IEventSender } from '../extension/IEventSender';
import { ILog } from '../extension/ILog';
import { TuneDbParamPlugin } from '../extension/TuneDbParamPlugin';
import { RdbConfig } from './RdbConfig';
import { RdbDatabase } from './RdbDatabase';

export class DatabaseBuilder {
  config: RdbConfig
  extension: Extension
  context: Context

  constructor(context: Context, config: RdbConfig) {
    this.context = context
    this.config = config
    this.extension = new Extension(config)
  }

  build(): RdbDatabase {
    const db = new RdbDatabase(this)
    return db
  }

  /**
   * 增加 log 输出
   * @param log
   * @returns
   */
  setLogger(log: ILog): DatabaseBuilder {
    this.extension.log = log
    return this
  }

  /**
   * 增加事件监控上报
   * @param eventSender
   * @returns
   */
  setEvent(eventSender: IEventSender): DatabaseBuilder {
    this.extension.eventSender = eventSender
    return this
  }

  /**
   * 增加 db 参数调控
   */
  setTuneParamPlugin(dbParamTuner: TuneDbParamPlugin): DatabaseBuilder {
    this.extension.tuneDbParamOptPlugin = dbParamTuner
    return this
  }
}