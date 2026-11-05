export type Limit = { kind: string; percentUsed: number; resetsAt?: string }

export type Reading = {
  ctx?: number
  limits: Limit[]
  // set by the usage API poll; shows usage from other sessions
  isLive: boolean
  now: number
}

declare module 'claude-code' {
  interface PluginState {
    'usage-weather': { reading: Reading | null }
  }
}
