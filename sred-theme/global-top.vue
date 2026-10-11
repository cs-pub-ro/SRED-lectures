<script setup lang="ts">
import { computed } from 'vue'
import { useDrawings } from '@slidev/client'
import { useTouyingConfig } from './composables/useTouyingConfig'
import DewdropLayer from './themes/dewdrop/global-layer.vue'
import SimpleLayer from './themes/simple/global-layer.vue'
import UniversityLayer from './themes/university/global-layer.vue'
import IscLayer from './themes/isc/global-layer.vue'
import { whiteboardOn } from './composables/useWhiteboard'

const { drawingEnabled, clear } = useDrawings()

defineOptions({ inheritAttrs: false })
const config = useTouyingConfig()
const component = computed(() => {
  if (config.value.preset === 'dewdrop') return DewdropLayer
  if (config.value.preset === 'simple') return SimpleLayer
  if (config.value.preset === 'university') return UniversityLayer
  if (config.value.preset === 'isc') return IscLayer
  throw new Error(`Unknown preset: ${config.value.preset}`)
})
</script>

<template>
  <component :is="component" v-bind="$attrs">
    <template v-for="(_, name) in $slots" #[name]="slotProps">
      <slot :name="name" v-bind="slotProps ?? {}" />
    </template>
  </component>
  <!-- whiteboard overlay: above slide, but below the native DrawingLayer -->
  <div v-if="whiteboardOn" class="absolute inset-0 bg-white" />
  <button v-if="drawingEnabled" @click="clear"
    class="absolute right-4 top-4 z-nav rounded border border-slate-300 bg-white px-3 py-1 text-sm text-slate-500 hover:bg-slate-100"
  >clear</button>
</template>
