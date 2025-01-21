import { ConvertParameter } from './converter/ConvertParameter';
import { PredicatesCondition } from '../../query/PredicatesCondition';
import relationalStore from '@ohos.data.relationalStore';
import { Op } from '../../query/Op';
import { ColumnType } from '../../decoration/ColumnType';
import { DiffItem } from '../../database/auto/DiffUtil';
import { EmbeddedNode } from '../../decoration/EmbeddedNode';

/**
 * 列约束
 */
export class Constraint {
  public unique: boolean;
  public notNull: boolean;

  constructor(unique: boolean, notNull: boolean) {
    this.unique = unique
    this.notNull = notNull
  }
}

/**
 * 列信息
 */
export class Property implements DiffItem {
  tableName: string
  type: ColumnType;
  name: string;
  primaryKey: boolean;
  columnName: string;
  constraint: Constraint | undefined;
  autoincrement: boolean;
  /**
   * Embedded 嵌套数据属性名称排序记录如：爷、父、子、孙
   */
  public embeddedChain: Array<EmbeddedNode> | undefined;
  /**
   * convert
   */
  public convertParam: ConvertParameter | undefined;

  constructor(tableName: string, type: ColumnType, name: string, primaryKey: boolean, columnName: string,
    autoincrement: boolean,
    embeddedChain?: Array<EmbeddedNode>, convertParam?: ConvertParameter, constraint?: Constraint) {
    this.tableName = tableName
    this.type = type;
    this.name = name;
    this.primaryKey = primaryKey;
    this.columnName = columnName;
    this.autoincrement = autoincrement;
    this.embeddedChain = embeddedChain
    this.convertParam = convertParam
    this.constraint = constraint
  }

  key(): string {
    return this.columnName;
  }

  equalTo(value: relationalStore.ValueType): PredicatesCondition {
    return new PredicatesCondition(Op.equalTo, this.columnName, value)
  }

  notEqualTo(value: relationalStore.ValueType): PredicatesCondition {
    return new PredicatesCondition(Op.notEqualTo, this.columnName, value);
  }

  contains(value: relationalStore.ValueType): PredicatesCondition {
    return new PredicatesCondition(Op.contains, this.columnName, value);
  }

  beginsWith(value: relationalStore.ValueType): PredicatesCondition {
    return new PredicatesCondition(Op.beginsWith, this.columnName, value);
  }

  endsWith(value: relationalStore.ValueType): PredicatesCondition {
    return new PredicatesCondition(Op.endsWith, this.columnName, value);
  }

  isNull(): PredicatesCondition {
    return new PredicatesCondition(Op.isNull, this.columnName);
  }

  isNotNull(): PredicatesCondition {
    return new PredicatesCondition(Op.isNotNull, this.columnName);
  }

  like(value: relationalStore.ValueType): PredicatesCondition {
    return new PredicatesCondition(Op.like, this.columnName, value);
  }

  glob(value: relationalStore.ValueType): PredicatesCondition {
    return new PredicatesCondition(Op.glob, this.columnName, value);
  }

  between(value1: relationalStore.ValueType, value2: relationalStore.ValueType): PredicatesCondition {
    return new PredicatesCondition(Op.between, this.columnName, value1, value2);
  }

  notBetween(value1: relationalStore.ValueType, value2: relationalStore.ValueType): PredicatesCondition {
    return new PredicatesCondition(Op.notBetween, this.columnName, value1, value2);
  }

  greaterThan(value: relationalStore.ValueType): PredicatesCondition {
    return new PredicatesCondition(Op.greaterThan, this.columnName, value);
  }

  lessThan(value: relationalStore.ValueType): PredicatesCondition {
    return new PredicatesCondition(Op.lessThan, this.columnName, value);
  }

  greaterThanOrEqualTo(value: relationalStore.ValueType): PredicatesCondition {
    return new PredicatesCondition(Op.greaterThanOrEqualTo, this.columnName, value);
  }

  lessThanOrEqualTo(value: relationalStore.ValueType): PredicatesCondition {
    return new PredicatesCondition(Op.lessThanOrEqualTo, this.columnName, value);
  }

  inOp(value: relationalStore.ValueType[]): PredicatesCondition {
    return new PredicatesCondition(Op.inOp, this.columnName, ...value);
  }

  notInOp(value: relationalStore.ValueType[]): PredicatesCondition {
    return new PredicatesCondition(Op.notInOp, this.columnName, ...value);
  }

  notContains(value: relationalStore.ValueType): PredicatesCondition {
    return new PredicatesCondition(Op.notContains, this.columnName, value);
  }

  notLike(value: relationalStore.ValueType): PredicatesCondition {
    return new PredicatesCondition(Op.notLike, this.columnName, value);
  }

  /**
   * 是否是嵌套 model 中的列
   */
  isEmbedded() {
    return this.embeddedChain?.length ?? 0 > 0
  }
}
