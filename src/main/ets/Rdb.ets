import { DatabaseBuilder } from './database/DatabaseBuilder';
import { RdbConfig } from './database/RdbConfig';
import { RdbError } from './error/RdbError';

/**
 * 创建
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

