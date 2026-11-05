import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

import type { Limit, Reading } from '../types'

const reading = atom({ plugin: 'usage-weather', key: 'reading' } as const, null)

const sky = (p: number) =>
  p < 30 ? '☀️ Sunny' : p < 55 ? '⛅ Partly cloudy' : p < 75 ? '☁️ Overcast' : p < 90 ? '🌧️ Rain' : '⛈️ Storm'

const label = (kind: string) =>
  kind === 'five_hour' ? '5h' : kind === 'seven_day' ? '7d' : kind

const eta = (iso: string | undefined, now: number) => {
  if (!iso) return ''
  const s = Math.max(0, Math.round((Date.parse(iso) - now) / 1000))
  const m = Math.floor(s / 60)
  return ` clears in ${m >= 60 ? `${Math.floor(m / 60)}h${m % 60}m` : `${m}m${String(s % 60).padStart(2, '0')}s`}`
}

const POLL_MS = 10_000 // shortcut: undocumented endpoint, 1s polling risks a 429; lower only if it tolerates it
const URL = 'https://api.anthropic.com/api/oauth/usage'

const parse = (text: string): Limit[] | null => {
  try {
    const j = JSON.parse(text)
    const out: Limit[] = []
    for (const kind of ['five_hour', 'seven_day']) {
      const w = j[kind]
      if (w && typeof w.utilization === 'number') {
        out.push({ kind, percentUsed: w.utilization, resetsAt: w.resets_at ?? undefined })
      }
    }
    return out.length ? out : null
  } catch {
    return null
  }
}

export const register: Register = on => {
  on('session.measure', async ($, e, next) => {
    // the poll's figures win; this session's own response only fills in before the first poll
    await update($, reading, prev => ({
      ctx: e.context.percent,
      limits: prev?.isLive ? prev.limits : e.rateLimits,
      isLive: prev?.isLive ?? false,
      now: prev?.now ?? 0,
    }))

    return next(e)
  })

  on('session.start', async ($, e, next) => {
    let isBusy = false

    // redraw each second so the countdown ticks; fetch on the slower POLL_MS cadence
    let last = 0
    $.clock.every(1000, async () => {
      if (isBusy) return
      isBusy = true
      try {
        const now = await $.clock.now()
        let live: Limit[] | null = null

        if (now - last >= POLL_MS) {
          last = now
          const auth = (await $.session.authorize())?.handle
          if (auth) {
            const res = await $.http.fetch(URL, {
              auth,
              headers: { 'anthropic-beta': 'oauth-2025-04-20' },
            })
            if (res.ok) live = parse(res.text)
          }
        }

        await update($, reading, prev => ({
          ctx: prev?.ctx,
          limits: live ?? prev?.limits ?? [],
          isLive: live !== null || (prev?.isLive ?? false),
          now,
        }))
      } catch {
        // keep the last figures; the next tick retries
      } finally {
        isBusy = false
      }
    })

    return next(e)
  })

  on('ui.render', { component: 'AbovePrompt' }, async ($, e, next) => {
    const r = await read($, reading)

    if (e.props.hasSurvey || r === null) {
      return next(e)
    }

    const { Box, Text } = $.ui.resolve(e)
    const ctx = r.ctx === undefined ? 'no reading' : `${sky(r.ctx)} ${Math.round(r.ctx)}%`

    return (
      <Box>
        <Text dimColor>{r.isLive ? '● ' : ''}Context: {ctx}</Text>
        {r.limits.map(l => (
          <Text key={l.kind} dimColor>
            {'  │  '}
            {label(l.kind)}: {sky(l.percentUsed)} {Math.round(l.percentUsed)}%
            {eta(l.resetsAt, r.now || Date.now())}
          </Text>
        ))}
      </Box>
    )
  })
}
