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

import { Extension } from '../extension/Extension';
import { IEventSender } from '../extension/IEventSender';
import { ILog } from '../extension/ILog';
import { TuneDbParamPlugin } from '../extension/TuneDbParamPlugin';
import { IOpenDelegate } from './IOpenDelegate';
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

  /**
   * 增加 db 生命周期派发
   */
  setLifecycleListener(openListener: IOpenDelegate): DatabaseBuilder {
    this.extension.openListener = openListener
    return this
  }
}