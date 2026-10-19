<script setup>
import { useNav } from '@slidev/client'
import { onMounted, onUnmounted } from 'vue'
import sredLogo from './public/sred-logo.png'
import ccLogo from './public/CC-by-nc-sa.png'
import downloadIcon from './public/download.svg'

const { isPrintMode, isPrint } = useNav()
const pdfUrl = import.meta.env.BASE_URL + 'slides.pdf'

/* Fix Mermaid icon sizing — two-pronged approach:
   1. Head CSS: constrains images BEFORE Mermaid's getBoundingClientRect()
   2. MutationObserver: patches inline styles AFTER Mermaid applies them */
const styleEl = document.createElement('style')
styleEl.textContent = `
  .nodeLabel img {
    width: 55px !important;
    max-width: 55px !important;
    height: auto !important;
    display: inline-block !important;
  }
`
document.head.appendChild(styleEl)

let observer = null
function fixMermaidImages() {
  document.querySelectorAll('.nodeLabel img').forEach(img => {
    img.style.setProperty('width', '55px', 'important')
    img.style.setProperty('max-width', '55px', 'important')
    img.style.setProperty('display', 'inline-block', 'important')
  })
}
onMounted(() => {
  fixMermaidImages()
  observer = new MutationObserver(fixMermaidImages)
  observer.observe(document.body, { childList: true, subtree: true })
})
onUnmounted(() => {
  if (observer) observer.disconnect()
})
</script>

<template>
  <footer style="position: absolute; bottom: 16px; left: 0; width: 100%; display: flex; justify-content: center; align-items: center; gap: 32px; z-index: 50; pointer-events: none;">
    
    <!-- Download PDF Button (Bottom Left) -->
    <a v-if="!isPrintMode && !isPrint" :href="pdfUrl" download style="position: absolute; left: 24px; top: 50%; transform: translateY(-50%); pointer-events: auto; text-decoration: none; display: flex;">
      <img :src="downloadIcon" alt="Download PDF" style="width: 20px; height: 20px; opacity: 0.5; transition: opacity 0.2s;" onmouseover="this.style.opacity='1'" onmouseout="this.style.opacity='0.5'" />
    </a>

    <!-- Centered Logos -->
    <a href="https://ocw.cs.pub.ro/courses/sred"><img :src="sredLogo" alt="SRED Logo" 
      style="height: 44px; object-fit: contain; opacity: 0.9; pointer-events: auto;" /></a>
    <a href="https://creativecommons.org/licenses/by-nc-sa/4.0/"><img :src="ccLogo" alt="CC BY-NC-SA License" 
      style="height: 32px; object-fit: contain; opacity: 0.9; pointer-events: auto;" /></a>
    
  </footer>
</template>
