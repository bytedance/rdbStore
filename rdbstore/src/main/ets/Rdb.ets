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

import { DatabaseBuilder } from './database/DatabaseBuilder';
import { RdbConfig } from './database/RdbConfig';
import { RdbError } from './error/RdbError';

/**
 * 数据库创建
 */
export namespace Rdb {

  export function databaseBuilder(context: Context, config: RdbConfig): DatabaseBuilder {
    if (!(context)) {
      throw new RdbError(ErrorMsg.INIT_ERROR)
    }
    return new DatabaseBuilder(context, config)
  }

  export enum ErrorMsg {
    INIT_ERROR = 'rdb_error_init_error',
    INPUT_CHECK_ERROR = 'rdb_error_input_check_error',
    PROCESS_ERROR = 'rdb_error_process_error'
  }
}

