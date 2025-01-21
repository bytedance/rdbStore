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

/**
 * event constants
 */
export namespace EventConstants {

  export const RDB_MONITOR = 'rdb_monitor'

  export const DB_NAME = 'db_name'

  export const TABLE_NAME = 'table_name'

  export const SCENE_NAME = 'scene_name'

  export const ERROR_NAME = 'error_name'

  export const ERROR_MSG = 'error_msg'

  export const DURATION = 'duration'

  export const SQL = 'sql'

  /**
   * init
   */
  export const INIT_SCENE = 'init_scene'

  /**
   * query
   */
  export const QUERY_SCENE = 'query_scene'

  /**
   * error
   */
  export const ERROR_SCENE = 'error_scene'

  /**
   * table size
   */
  export const TABLE_SIZE_SCENE = 'table_size_scene'
}