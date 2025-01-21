import { Rdb } from '../Rdb';
import { RdbMonitor } from '../util/RdbMonitor';

/**
 * rdb 异常
 */
export class RdbError extends Error {
  constructor(msg: Rdb.ErrorMsg, err: Error = new Error, monitor?: RdbMonitor) {
    super(`${msg.toString()} detail: ${err.message}`);
    monitor?.reportError(msg, err)
  }
}