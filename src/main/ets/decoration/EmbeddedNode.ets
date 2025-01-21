import { ClassConstructor } from "../util/ClassConstructor"

/**
 * 嵌套结点信息
 */
export interface EmbeddedNode {
  /**
   * 嵌套类在外层类中的属性名
   */
  propName: string
  /**
   * 嵌套类的构造函数
   */
  cls: ClassConstructor<Object>
}