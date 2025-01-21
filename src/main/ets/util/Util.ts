import { ClassConstructor } from './ClassConstructor';

export namespace Util {
  export function getConstructorOf(obj: ESObject): ClassConstructor<ESObject> {
    return Object.getPrototypeOf(obj).constructor
  }

  export function obtain<T>(block: () => T): T {
    return block()
  }

  /**
   * 计算所有 IterableIterator 中元素的数量
   * @param iterableIterator
   * @returns
   */
  export function countElements(iterableIterator: IterableIterator<any>): number {
    let count = 0;
    for (const _ of iterableIterator) {
      count++;
    }
    return count;
  }
}
