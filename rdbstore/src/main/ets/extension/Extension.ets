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