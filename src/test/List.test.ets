import RdbDatabaseTest from './RdbDatabase.test'
import localUnitTest from './LocalUnit.test';

export default function testsuite() {
  localUnitTest();
  RdbDatabaseTest()
}