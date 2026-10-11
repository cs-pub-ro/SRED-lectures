import type { NavOperations, ShortcutOptions } from '@slidev/types'
import { defineShortcutsSetup } from '@slidev/types'
import { useDrawings } from '@slidev/client'
import { whiteboardOn } from '../composables/useWhiteboard'

export default defineShortcutsSetup((_nav, base) => {
  const { drawingEnabled } = useDrawings()
  return [
    ...base, {
      // 'b': toggle custom Drawing over Whiteboard
      key: 'b',
      fn: () => {
        const on = !whiteboardOn.value
        whiteboardOn.value = on
        drawingEnabled.value = on
      },
    },
  ]
})
