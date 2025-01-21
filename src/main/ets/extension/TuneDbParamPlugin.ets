import { RdbDatabase } from "../database/RdbDatabase"

const JOURNAL_MODE = 'journal_mode'
const PAGE_SIZE = 'page_size'
const SYNCHRONOUS = 'synchronous'
const JOURNAL_SIZE_LIMIT = 'journal_size_limit'
const WAL_AUTOCHECKPOINT = 'wal_autocheckpoint'
const FOREIGN_KEYS = 'foreign_keys'
const RECURSIVE_TRIGGERS = 'recursive_triggers'

/**
 * db 品质调参
 */
export abstract class TuneDbParamPlugin {
  private database: RdbDatabase

  constructor(dataBase: RdbDatabase) {
    this.database = dataBase
  }

  /**
   * 调参入口
   */
  abstract initTuneParams(): Promise<void>

  /**
   * 获取 db 参数
   * @returns
   */
  async getParams(): Promise<Record<string, number | string>> {
    const param: Record<string, number | string> = {}
    param[JOURNAL_MODE] = await this.getJournalMode()
    param[PAGE_SIZE] = await this.getPageSize()
    param[SYNCHRONOUS] = await this.getSynchronous()
    param[JOURNAL_SIZE_LIMIT] = await this.getJournalSizeLimit()
    param[WAL_AUTOCHECKPOINT] = await this.getWalAutoCheckpoint()
    param[FOREIGN_KEYS] = await this.getForeignKeys()
    param[RECURSIVE_TRIGGERS] = await this.getRecursiveTriggers()
    return param
  }

  async getJournalMode(): Promise<string> {
    const dao = await this.database.getRdbImpl();
    return await dao.execute('PRAGMA journal_mode') as string
  }

  setJournalMode(mode: string): void {
    this.database.getRdbImpl().then((dao) => {
      dao.execute(`PRAGMA journal_mode = ${mode}`)
    })
  }

  async getPageSize(): Promise<number> {
    const dao = await this.database.getRdbImpl();
    return await dao.execute('PRAGMA page_size') as number
  }

  setPageSize(size: number): void {
    this.database.getRdbImpl().then((dao) => {
      dao.execute(`PRAGMA page_size = ${size}`)
    })
  }

  async getSynchronous(): Promise<number> {
    const dao = await this.database.getRdbImpl();
    return await dao.execute('PRAGMA synchronous') as number
  }

  setSynchronous(synchronous: number): void {
    this.database.getRdbImpl().then((dao) => {
      dao.execute(`PRAGMA synchronous = ${synchronous}`)
    })
  }

  async getJournalSizeLimit(): Promise<number> {
    const dao = await this.database.getRdbImpl();
    return await dao.execute('PRAGMA journal_size_limit') as number
  }

  setJournalSizeLimit(journalSizeLimit: number): void {
    this.database.getRdbImpl().then((dao) => {
      dao.execute(`PRAGMA journal_size_limit = ${journalSizeLimit}`)
    })
  }

  async getWalAutoCheckpoint(): Promise<number> {
    const dao = await this.database.getRdbImpl();
    return await dao.execute('PRAGMA wal_autocheckpoint') as number
  }

  setWalAutoCheckpoint(walAutoCheckpoint: number): void {
    this.database.getRdbImpl().then((dao) => {
      dao.execute(`PRAGMA wal_autocheckpoint = ${walAutoCheckpoint}`)
    })
  }

  async getForeignKeys(): Promise<number> {
    const dao = await this.database.getRdbImpl();
    return await dao.execute('PRAGMA foreign_keys') as number
  }

  setForeignKeys(foreignKeys: number): void {
    this.database.getRdbImpl().then((dao) => {
      dao.execute(`PRAGMA foreign_keys = ${foreignKeys}`)
    })
  }

  async getRecursiveTriggers(): Promise<number> {
    const dao = await this.database.getRdbImpl();
    return await dao.execute('PRAGMA recursive_triggers') as number
  }

  setRecursiveTriggers(recursiveTriggers: number): void {
    this.database.getRdbImpl().then((dao) => {
      dao.execute(`PRAGMA recursive_triggers = ${recursiveTriggers}`)
    })
  }
}