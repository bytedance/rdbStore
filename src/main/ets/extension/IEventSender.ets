/**
 * event send interface
 */
export interface IEventSender {
  /**
   * send event
   */
  send(key: string, params: Record<string, EventParamsBaseType>): void
}

export type EventParamsBaseType = string | number | boolean;

/**
 * default fall back event sender
 */
export class EventSender implements IEventSender {
  send(key: string, params: Record<string, EventParamsBaseType>): void {
  }
}

