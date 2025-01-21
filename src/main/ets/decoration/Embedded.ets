import { RdbConst } from '../RdbConst';
import { ClassConstructor } from '../util/ClassConstructor';

export function Embedded<EmbeddedClass>(info: EmbeddedInfo<EmbeddedClass>): PropertyDecorator {
  return (target: object, propertyKey) => {
    const embeddedMeta: object = target[RdbConst.EMBEDDED] ?? new Object
    if ((typeof propertyKey === 'string')) {
      embeddedMeta[propertyKey] = info
    }
    target[RdbConst.EMBEDDED] = embeddedMeta
  };
}

/**
 * 嵌套信息
 */
export interface EmbeddedInfo<EmbeddedClass> {
  /**
   * 前缀，该前缀会自动增加在数据库列中作为列名，为嵌套类下避免列名重复语法糖
   * 若嵌套类中不存在重复的列名，则不使用即可
   */
  prefix?: string,
  /**
   * 嵌套的类型
   */
  targetClass: ClassConstructor<EmbeddedClass>
}

class InnerModel {
  name: string = ''
}

class Test {
  @Embedded({ prefix: '', targetClass: InnerModel })
  name: string = ''
}


