/**
 * 类构造器
 */
export type ClassConstructor<T> = {
  new(...args: any[]): T
}