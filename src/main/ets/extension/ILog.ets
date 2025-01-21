/**
 * log interface
 */
export interface ILog {
  /**
   * debug
   */
  d(tag: string, message: string): void

  /**
   * info
   * @param message 日志内容
   */
  i(tag: string, message: string): void

  /**
   * warn
   */
  w(tag: string, message: string): void

  /**
   * error
   */
  e(tag: string, message: string): void
}

/**
 * default log
 */
export class LogImpl implements ILog {
  d(tag: string, message: string): void {

  }

  i(tag: string, message: string): void {

  }

  w(tag: string, message: string): void {

  }

  e(tag: string, message: string): void {

  }
}