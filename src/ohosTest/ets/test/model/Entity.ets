import {
  BigIntToStringConvertor,
  Columns,
  ColumnType,
  Embedded,
  Entity
} from '../../../../../Index';


export class Sun {
  @Columns({
    name: 'sid',
    type: ColumnType.INTEGER
  })
  id: number | null = null
  @Columns({
    name: 'sname',
    type: ColumnType.TEXT
  })
  name: string = ''
  @Columns({ name: 'sbigId', type: ColumnType.TEXT, convertor: BigIntToStringConvertor })
  bigId: bigint = 1n
}

export class Child {
  @Columns({
    name: 'cid',
    type: ColumnType.INTEGER,
    autoincrement: true
  })
  id: number | null = null
  @Columns({
    name: 'cname',
    type: ColumnType.TEXT
  })
  name: string | null = null
  @Columns({ name: 'cbigId', type: ColumnType.TEXT, convertor: BigIntToStringConvertor })
  bigId: bigint = 1n
  @Embedded({ targetClass: Sun })
  sun: Sun = new Sun()
}

@Entity({
  tableName: 'SampleEntity',
  index: [{ name: 'idIndex', columnName: ['age', 'id'] },
    { name: 'idIndex2', columnName: ['id'], unique: true }]
})
export class SampleEntity {
  @Columns({
    name: 'id',
    type: ColumnType.INTEGER,
    isPrimaryKey: true,
    autoincrement: true
  })
  id: number | null = null;
  @Columns({ name: 'age', type: ColumnType.INTEGER })
  age: number = -1
  @Columns({ name: 'name', type: ColumnType.TEXT })
  name: string = ''
  @Columns({ name: 'bigId', type: ColumnType.TEXT, convertor: BigIntToStringConvertor })
  bigId: bigint = 1n
  @Embedded({
    prefix: '',
    targetClass: Child
  })
  child: Child = new Child()
}


export class Sample extends SampleEntity {
}



@Entity({
  tableName: 'SampleEntity2',
  index: [{ name: 'SampleEntity2idIndex', columnName: ['age', 'id'] },
    { name: 'SampleEntity2idIndex2', columnName: ['id'], unique: true }]
})
export class SampleEntity2 {
  @Columns({
    name: 'id',
    type: ColumnType.INTEGER,
    isPrimaryKey: true,
    autoincrement: true
  })
  id: number | null = null;
  @Columns({ name: 'age', type: ColumnType.INTEGER })
  age: number = -1
  @Columns({ name: 'name', type: ColumnType.TEXT })
  name: string = ''
  @Columns({ name: 'bigId', type: ColumnType.TEXT, convertor: BigIntToStringConvertor })
  bigId: bigint = 1n
  @Embedded({
    prefix: '',
    targetClass: Child
  })
  child: Child

  constructor(child: Child) {
    this.child = child
  }
}


@Entity({
  tableName: 'SampleEntity3',
  index: [{ name: 'SampleEntity3idIndex', columnName: ['age', 'id'] }]
})
export class SampleEntity3 {
  @Columns({
    name: 'id',
    type: ColumnType.INTEGER,
    isPrimaryKey: true,
    autoincrement: true
  })
  id: number | null = null;
  @Columns({ name: 'age', type: ColumnType.INTEGER })
  age: number = -1
  @Columns({ name: 'name', type: ColumnType.TEXT })
  name: string = ''
  @Columns({ name: 'bigId', type: ColumnType.TEXT, convertor: BigIntToStringConvertor })
  bigId: bigint = 1n
  @Embedded({
    prefix: '',
    targetClass: Child
  })
  child: Child = new Child()
}



@Entity({
  tableName: 'SampleEntity4',
  index: [{ name: 'SampleEntity4idIndex', columnName: ['age', 'id'] }]
})
export class SampleEntity4 {
  @Columns({
    name: 'id',
    type: ColumnType.INTEGER,
    isPrimaryKey: true,
    autoincrement: true
  })
  id: number | null = null;
  @Columns({ name: 'age', type: ColumnType.INTEGER })
  age: number = -1
  @Columns({ name: 'name', type: ColumnType.TEXT })
  name: string = ''
  @Columns({ name: 'bigId', type: ColumnType.TEXT, convertor: BigIntToStringConvertor })
  bigId: bigint = 1n
  @Embedded({
    prefix: '',
    targetClass: Child
  })
  child: Child = new Child()
}


@Entity({
  tableName: 'SampleEntity5',
  index: [{ name: 'SampleEntity5idIndex', columnName: ['age', 'id'] }]
})
export class SampleEntity5 {
  @Columns({
    name: 'id',
    type: ColumnType.INTEGER,
    isPrimaryKey: true,
    autoincrement: true
  })
  id: number | null = null;
  @Columns({ name: 'age', type: ColumnType.INTEGER })
  age: number = -1
  @Columns({ name: 'name', type: ColumnType.TEXT })
  name: string = ''
  @Columns({ name: 'bigId', type: ColumnType.TEXT, convertor: BigIntToStringConvertor })
  bigId: bigint = 1n
  @Embedded({
    prefix: '',
    targetClass: Child
  })
  child: Child = new Child()
}



@Entity({
  tableName: 'SampleEntity6',
  index: [{ name: 'SampleEntity6idIndex', columnName: ['age', 'id'] }]
})
export class SampleEntity6 {
  @Columns({
    name: 'id',
    type: ColumnType.INTEGER,
    isPrimaryKey: true,
    autoincrement: true
  })
  id: number | null = null;
  @Columns({ name: 'age', type: ColumnType.INTEGER })
  age: number = -1
  @Columns({ name: 'name', type: ColumnType.TEXT })
  name: string = ''
  @Columns({ name: 'bigId', type: ColumnType.TEXT, convertor: BigIntToStringConvertor })
  bigId: bigint = 1n
  @Embedded({
    prefix: '',
    targetClass: Child
  })
  child: Child = new Child()
}


@Entity({
  tableName: 'SampleEntity7',
  index: [{ name: 'SampleEntity7idIndex', columnName: ['age', 'id'] }]
})
export class SampleEntity7 {
  @Columns({
    name: 'id',
    type: ColumnType.INTEGER,
    isPrimaryKey: true,
    autoincrement: true
  })
  id: number | null = null;
  @Columns({ name: 'age', type: ColumnType.INTEGER })
  age: number = -1
  @Columns({ name: 'name', type: ColumnType.TEXT })
  name: string = ''
  @Columns({ name: 'bigId', type: ColumnType.TEXT, convertor: BigIntToStringConvertor })
  bigId: bigint = 1n
  @Embedded({
    prefix: '',
    targetClass: Child
  })
  child: Child = new Child()
}



@Entity({
  tableName: 'SampleEntity8',
  index: [{ name: 'SampleEntity8idIndex', columnName: ['age', 'id'] }]
})
export class SampleEntity8 {
  @Columns({
    name: 'id',
    type: ColumnType.INTEGER,
    isPrimaryKey: true,
    autoincrement: true
  })
  id: number | null = null;
  @Columns({ name: 'age', type: ColumnType.INTEGER })
  age: number = -1
  @Columns({ name: 'name', type: ColumnType.TEXT })
  name: string = ''
  @Columns({ name: 'bigId', type: ColumnType.TEXT, convertor: BigIntToStringConvertor })
  bigId: bigint = 1n
  @Embedded({
    prefix: '',
    targetClass: Child
  })
  child: Child = new Child()
}


@Entity({
  tableName: 'SampleEntity9',
  index: [{ name: 'SampleEntity9idIndex', columnName: ['age', 'id'] }]
})
export class SampleEntity9 {
  @Columns({
    name: 'id',
    type: ColumnType.INTEGER,
    isPrimaryKey: true,
    autoincrement: true
  })
  id: number | null = null;
  @Columns({ name: 'age', type: ColumnType.INTEGER })
  age: number = -1
  @Columns({ name: 'name', type: ColumnType.TEXT })
  name: string = ''
  @Columns({ name: 'bigId', type: ColumnType.TEXT, convertor: BigIntToStringConvertor })
  bigId: bigint = 1n
  @Embedded({
    prefix: '',
    targetClass: Child
  })
  child: Child = new Child()
}



@Entity({
  tableName: 'SampleEntity10',
  index: [{ name: 'SampleEntity10idIndex', columnName: ['age', 'id'] }]
})
export class SampleEntity10 {
  @Columns({
    name: 'id',
    type: ColumnType.INTEGER,
    isPrimaryKey: true,
    autoincrement: true
  })
  id: number | null = null;
  @Columns({ name: 'age', type: ColumnType.INTEGER })
  age: number = -1
  @Columns({ name: 'name', type: ColumnType.TEXT })
  name: string = ''
  @Columns({ name: 'bigId', type: ColumnType.TEXT, convertor: BigIntToStringConvertor })
  bigId: bigint = 1n
  @Embedded({
    prefix: '',
    targetClass: Child
  })
  child: Child = new Child()
}


@Entity({
  tableName: 'SampleEntity11',
  index: [{ name: 'SampleEntity11idIndex', columnName: ['age', 'id'] }]
})
export class SampleEntity11 {
  @Columns({
    name: 'id',
    type: ColumnType.INTEGER,
    isPrimaryKey: true,
    autoincrement: true
  })
  id: number | null = null;
  @Columns({ name: 'age', type: ColumnType.INTEGER })
  age: number = -1
  @Columns({ name: 'name', type: ColumnType.TEXT })
  name: string = ''
  @Columns({ name: 'bigId', type: ColumnType.TEXT, convertor: BigIntToStringConvertor })
  bigId: bigint = 1n
  @Embedded({
    prefix: '',
    targetClass: Child
  })
  child: Child = new Child()
}



@Entity({
  tableName: 'SampleEntity12',
  index: [{ name: 'SampleEntity12idIndex', columnName: ['age', 'id'] }]
})
export class SampleEntity12 {
  @Columns({
    name: 'id',
    type: ColumnType.INTEGER,
    isPrimaryKey: true,
    autoincrement: true
  })
  id: number | null = null;
  @Columns({ name: 'age', type: ColumnType.INTEGER })
  age: number = -1
  @Columns({ name: 'name', type: ColumnType.TEXT })
  name: string = ''
  @Columns({ name: 'bigId', type: ColumnType.TEXT, convertor: BigIntToStringConvertor })
  bigId: bigint = 1n
  @Embedded({
    prefix: '',
    targetClass: Child
  })
  child: Child = new Child()
}


@Entity({
  tableName: 'SampleEntity13',
  index: [{ name: 'SampleEntity13idIndex', columnName: ['age', 'id'] }]
})
export class SampleEntity13 {
  @Columns({
    name: 'id',
    type: ColumnType.INTEGER,
    isPrimaryKey: true,
    autoincrement: true
  })
  id: number | null = null;
  @Columns({ name: 'age', type: ColumnType.INTEGER })
  age: number = -1
  @Columns({ name: 'name', type: ColumnType.TEXT })
  name: string = ''
  @Columns({ name: 'bigId', type: ColumnType.TEXT, convertor: BigIntToStringConvertor })
  bigId: bigint = 1n
  @Embedded({
    prefix: '',
    targetClass: Child
  })
  child: Child = new Child()
}



@Entity({
  tableName: 'SampleEntity14',
  index: [{ name: 'SampleEntity14idIndex', columnName: ['age', 'id'] }]
})
export class SampleEntity14 {
  @Columns({
    name: 'id',
    type: ColumnType.INTEGER,
    isPrimaryKey: true,
    autoincrement: true
  })
  id: number | null = null;
  @Columns({ name: 'age', type: ColumnType.INTEGER })
  age: number = -1
  @Columns({ name: 'name', type: ColumnType.TEXT })
  name: string = ''
  @Columns({ name: 'bigId', type: ColumnType.TEXT, convertor: BigIntToStringConvertor })
  bigId: bigint = 1n
  @Embedded({
    prefix: '',
    targetClass: Child
  })
  child: Child = new Child()
}

@Entity({
  tableName: 'SampleEntity15',
  index: [{ name: 'SampleEntity15idIndex', columnName: ['age', 'id'] }]
})
export class SampleEntity15 {
  @Columns({
    name: 'id',
    type: ColumnType.INTEGER,
    isPrimaryKey: true,
    autoincrement: true
  })
  id: number | null = null;
  @Columns({ name: 'age', type: ColumnType.INTEGER })
  age: number = -1
  @Columns({ name: 'name', type: ColumnType.TEXT })
  name: string = ''
  @Columns({ name: 'bigId', type: ColumnType.TEXT, convertor: BigIntToStringConvertor })
  bigId: bigint = 1n
  @Embedded({
    prefix: '',
    targetClass: Child
  })
  child: Child = new Child()
}

@Entity({
  tableName: 'SampleEntity16',
  index: [{ name: 'SampleEntity16idIndex', columnName: ['age', 'id'] }]
})
export class SampleEntity16 {
  @Columns({
    name: 'id',
    type: ColumnType.INTEGER,
    isPrimaryKey: true,
    autoincrement: true
  })
  id: number | null = null;
  @Columns({ name: 'age', type: ColumnType.INTEGER })
  age: number = -1
  @Columns({ name: 'name', type: ColumnType.TEXT })
  name: string = ''
  @Columns({ name: 'bigId', type: ColumnType.TEXT, convertor: BigIntToStringConvertor })
  bigId: bigint = 1n
  @Embedded({
    prefix: '',
    targetClass: Child
  })
  child: Child = new Child()
}

@Entity({
  tableName: 'SampleEntity17',
  index: [{ name: 'SampleEntity17idIndex', columnName: ['age', 'id'] }]
})
export class SampleEntity17 {
  @Columns({
    name: 'id',
    type: ColumnType.INTEGER,
    isPrimaryKey: true,
    autoincrement: true
  })
  id: number | null = null;
  @Columns({ name: 'age', type: ColumnType.INTEGER })
  age: number = -1
  @Columns({ name: 'name', type: ColumnType.TEXT })
  name: string = ''
  @Columns({ name: 'bigId', type: ColumnType.TEXT, convertor: BigIntToStringConvertor })
  bigId: bigint = 1n
  @Embedded({
    prefix: '',
    targetClass: Child
  })
  child: Child = new Child()
}

@Entity({
  tableName: 'SampleEntity18',
  index: [{ name: 'SampleEntity18idIndex', columnName: ['age', 'id'] }]
})
export class SampleEntity18 {
  @Columns({
    name: 'id',
    type: ColumnType.INTEGER,
    isPrimaryKey: true,
    autoincrement: true
  })
  id: number | null = null;
  @Columns({ name: 'age', type: ColumnType.INTEGER })
  age: number = -1
  @Columns({ name: 'name', type: ColumnType.TEXT })
  name: string = ''
  @Columns({ name: 'bigId', type: ColumnType.TEXT, convertor: BigIntToStringConvertor })
  bigId: bigint = 1n
  @Embedded({
    prefix: '',
    targetClass: Child
  })
  child: Child = new Child()
}

@Entity({
  tableName: 'SampleEntity19',
  index: [{ name: 'SampleEntity19idIndex', columnName: ['age', 'id'] }]
})
export class SampleEntity19 {
  @Columns({
    name: 'id',
    type: ColumnType.INTEGER,
    isPrimaryKey: true,
    autoincrement: true
  })
  id: number | null = null;
  @Columns({ name: 'age', type: ColumnType.INTEGER })
  age: number = -1
  @Columns({ name: 'name', type: ColumnType.TEXT })
  name: string = ''
  @Columns({ name: 'bigId', type: ColumnType.TEXT, convertor: BigIntToStringConvertor })
  bigId: bigint = 1n
  @Embedded({
    prefix: '',
    targetClass: Child
  })
  child: Child = new Child()
}

@Entity({
  tableName: 'SampleEntity20',
  index: [{ name: 'SampleEntity20idIndex', columnName: ['age', 'id'] }]
})
export class SampleEntity20 {
  @Columns({
    name: 'id',
    type: ColumnType.INTEGER,
    isPrimaryKey: true,
    autoincrement: true
  })
  id: number | null = null;
  @Columns({ name: 'age', type: ColumnType.INTEGER })
  age: number = -1
  @Columns({ name: 'name', type: ColumnType.TEXT })
  name: string = ''
  @Columns({ name: 'bigId', type: ColumnType.TEXT, convertor: BigIntToStringConvertor })
  bigId: bigint = 1n
  @Embedded({
    prefix: '',
    targetClass: Child
  })
  child: Child = new Child()
}