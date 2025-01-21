import { DbStructInfo } from '../model/relation/DbStructInfo'
import relationalStore from '@ohos.data.relationalStore'
import { Property } from '../model/relation/Property'
import { ClassConstructor } from '../util/ClassConstructor'
import { PropertyConverter } from '../model/relation/converter/ConvertParameter'
import { EmbeddedNode } from '../decoration/EmbeddedNode'

/**
 * sql 构建工具
 */
export namespace SqlCompiler {

  /**
   * 生成表创建语句
   */
  export function getTableCreateSql(cls: ClassConstructor<Object>): string {


    const tableInfo = DbStructInfo.getInstance().getTableMeta(cls)
    const props = DbStructInfo.getInstance().getPropertyArray(cls)

    if (!(tableInfo && props && props.length > 0)) {
      throw Error(`SqlCompiler getTableCreateSql error ! init info miss `)
    }

    let sql = "CREATE TABLE IF NOT EXISTS " + tableInfo?.tableName + " (";

    let num = props.length;

    let primaryKeyPropList = props.filter((item) => item.primaryKey)

    props.forEach((property, index) => {
      sql += property.columnName + ' ' + property.type + ' ';

      if (property.primaryKey && primaryKeyPropList.length == 1) {
        sql += ' PRIMARY KEY ';
        if (property.autoincrement) {
          sql += ' AUTOINCREMENT '
        }
      }

      let constraints = property.constraint;
      if (constraints) {
        if (constraints.unique) {
          sql += ' UNIQUE ';
        }

        if (constraints.notNull) {
          sql += ' NOT NULL ';
        }
      }
      if (index < num - 1) {
        sql += ',';
      }
    })

    if (primaryKeyPropList.length > 1) {
      sql += `, PRIMARY KEY (${primaryKeyPropList.map(item => item.columnName).join(', ')})`
    }
    sql += ")";

    return sql;
  }

  /**
   * 创建索引
   */
  export function getTableIndexSql(cls: ClassConstructor<Object>): Array<string> {
    const result: Array<string> = new Array
    const tableInfo = DbStructInfo.getInstance().getTableMeta(cls)
    tableInfo?.index.forEach(item => {
      let sql = ''
      if (item.unique) {
        sql = `CREATE UNIQUE INDEX IF NOT EXISTS ${item.name} ON ${tableInfo.tableName} (${item.columnName.join(', ')})`
      } else {
        sql = `CREATE INDEX IF NOT EXISTS ${item.name} ON ${tableInfo.tableName} (${item.columnName.join(', ')})`
      }
      result.push(sql)
    })

    return result
  }

  /**
   * 批量绑定 ValuesBucket
   * @param entities
   * @returns
   */
  export function modelsToValuesBucket<T extends object>(entityCls: ClassConstructor<T>,
    entities: Array<T>): Array<relationalStore.ValuesBucket> {
    const result: Array<relationalStore.ValuesBucket> = new Array()
    entities.forEach(item => {
      if (item) {
        result.push(modelToValuesBucket(entityCls, item))
      }
    })
    return result
  }

  /**
   * ModelBean => ValuesBucket
   * @param stmt
   * @param entity
   */
  export function modelToValuesBucket<T extends object>(entityCls: ClassConstructor<T>, entity: T,
    values: relationalStore.ValuesBucket = {}): relationalStore.ValuesBucket {
    const props = DbStructInfo.getInstance().getPropertyArray(entityCls)

    if (props) {
      for (const property of props) {

        // Embedded注解修饰处理 array : [grandparent、parent、child、sun]
        if (property.isEmbedded()) {

          // 溯源找到嵌套类中 property 所在的 model
          const innerTargetModel = getEntityValueForEmbeddedProp(property.embeddedChain!, entity)

          // 赋值
          if (innerTargetModel) {
            columnBindValue(values, property, innerTargetModel)
          }
        } else {
          if (entity[property.name] != undefined) {
            columnBindValue(values, property, entity)
          }
        }
      }
    }
    return values
  }


  /**
   * 批量完成查询结果解析
   */
  export function resultToModels<T extends object>(entityCls: ClassConstructor<T>,
    resultSet: relationalStore.ResultSet): Array<T> {
    const re: Array<T> = new Array()
    if (resultSet.goToFirstRow()) {
      do {
        re.push(resultToModel(entityCls, resultSet))
      } while (resultSet.goToNextRow());
    }
    return re
  }

  /**
   * ResultSet => ModelBean
   * @param resultSet
   * @param offset
   * @returns
   */
  export function resultToModel<T extends object>(entityCls: ClassConstructor<T>,
    resultSet: relationalStore.ResultSet): T {
    const entity = new entityCls();
    const properties = DbStructInfo.getInstance().getPropertyArray(entityCls)
    const row = resultSet.getRow()

    properties?.forEach((property, index) => {
      const dbPropertyValue: Object = row[property.columnName] as object

      // embedded注解修饰处理
      if (property.isEmbedded()) {
        const targetModel = getEntityValueForEmbeddedProp(property.embeddedChain!, entity)
        // 叶子节点赋值
        parseColumnValue(dbPropertyValue, targetModel!, property)
      } else {
        // 叶子节点赋值
        parseColumnValue(dbPropertyValue, entity, property)
      }
    })
    return entity;
  }

  /**
   * entity select 列形式：
   * 返回所有表中列：a, b, c, d, e 方便构造：select a, b, c, d, e
   * @param entityCls
   */
  export function getSelectColumns<T extends object>(...entityCls: Array<ClassConstructor<T>>): string {
    const props: Array<string> = new Array

    entityCls.forEach(item => {
      const tableProp = DbStructInfo.getInstance().getPropertyArray(item)
      if (tableProp) {
        props.push(...tableProp.map((prop) => prop.columnName))
      }
    })

    const result = props.join(', ')

    return result
  }

  /**
   * 按列查询结果赋值
   * @param value
   * @param entityModel
   * @param property
   */
  function parseColumnValue(value: Object, entityModel: object, property: Property) {
    let columnValue = value
    const convertParamObj = property.convertParam;

    if (convertParamObj) {
      const convertTarget: ClassConstructor<PropertyConverter<Object, Object>> = convertParamObj.getConverter();
      const convertImpl = new convertTarget();

      if (convertImpl instanceof PropertyConverter) {
        columnValue = convertImpl.convertToEntityProperty(value);
      }
    }

    // 节点赋值
    entityModel[property.name] = columnValue;
  }

  /**
   * 根据属性所在的层级获取该层级 model
   * @param array
   * @param model
   * @returns
   */
  function getEntityValueForEmbeddedProp<T extends object>(array: Array<EmbeddedNode>, model: T) {
    let current: object = model;
    for (const item of array) {
      if (current[item.propName]) {
        current = current[item.propName];
      } else {
        const child = new item.cls()
        current[item.propName] = child
        current = child
      }
    }
    return current;
  }

  /**
   * 处理 column bind value 兼容列上带有 Convert 情况
   * @param stmt
   * @param property
   */
  function columnBindValue<T extends object>(values: relationalStore.ValuesBucket, property: Property, entity: T) {
    const convertParamObj = property.convertParam;
    if (convertParamObj) {
      const convertTarget: ClassConstructor<PropertyConverter<Object, Object>> = convertParamObj.getConverter();
      const convertImpl = new convertTarget();
      if (convertImpl instanceof PropertyConverter) {
        values[property.columnName] =
          convertImpl.convertToDatabaseValue(entity[property.name]) as relationalStore.ValueType
      }
    } else {
      values[property.columnName] = entity[property.name]
    }
  }
}