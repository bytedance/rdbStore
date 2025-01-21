/*
 * Copyright (2024) Bytedance Ltd. and/or its affiliates
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { Migration } from './Migration';
import { Extension } from '../../extension/Extension';

/**
 * 维护数据库升级逻辑
 */
export class MigrationContainer {
  private TAG = 'MigrationContainer'
  private mMigrations: Map<number, Map<number, Migration>> = new Map();
  private extension: Extension

  constructor(extension: Extension) {
    this.extension = extension
  }

  addMigrations(migrations: Array<Migration>) {
    for (const migration of migrations) {
      this.addMigration(migration);
    }
  }

  private addMigration(migration: Migration) {
    const start = migration.preVersion;
    const end = migration.toVersion;
    let targetMap = this.mMigrations.get(start);
    if (!targetMap) {
      targetMap = new Map();
      this.mMigrations.set(start, targetMap);
    }
    const existing = targetMap.get(end);
    if (existing) {
      this.extension.log?.w(this.TAG, `Overriding migration from: ${existing.preVersion} to: ${migration.toVersion}`);
      if (existing.preVersion == migration.preVersion && existing.preVersion == migration.toVersion) {
        throw Error('duplicate migration: from: ${existing.preVersion} to: ${migration.toVersion}')
      }
    }

    targetMap.set(end, migration);
  }

  /**
   * return migrations from start to end
   * @param start
   * @param end
   * @returns
   */
  findMigrationPath(start: number, end: number): Migration[] | null {
    if (start === end || start > end) {
      return [];
    }
    const result: Migration[] = [];
    return this.findUpMigrationPath(result, start, end);
  }

  private findUpMigrationPath(result: Migration[], start: number, end: number): Migration[] | null {
    while (start < end) {
      const targetNodes = this.mMigrations.get(start);
      if (!targetNodes) {
        return null;
      }
      const keySet = new Set(Array.from(targetNodes.keys()).sort((a, b) => b - a));
      let found = false
      for (const targetVersion of keySet) {
        const shouldAddToPath = targetVersion <= end && targetVersion > start;
        if (shouldAddToPath) {
          result.push(targetNodes.get(targetVersion)!);
          start = targetVersion;
          found = true
          break;
        }
      }
      if (!found) {
        return null;
      }
    }
    return result;
  }
}