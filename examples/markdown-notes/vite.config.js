import { defineConfig } from 'vite'
import fs from 'node:fs'
import path from 'node:path'

function inlineBuiltAssets() {
  let outDir = 'dist'

  return {
    name: 'markdown-notes-inline-built-assets',
    configResolved(config) {
      outDir = path.resolve(config.root, config.build.outDir)
    },
    closeBundle() {
      const htmlPath = path.join(outDir, 'index.html')
      let html = fs.readFileSync(htmlPath, 'utf8')

      const assetPath = (file) => {
        const normalized = file.replace(/^\//, '').replace(/^\.\//, '')
        return path.join(outDir, normalized)
      }

      html = html.replace(
        /<link\b([^>]*?)href="([^"]+\.css)"([^>]*)>/g,
        (_tag, _before, href, _after) => {
          const css = fs.readFileSync(assetPath(href), 'utf8')
          return `<style>\n${css}\n</style>`
        },
      )

      html = html.replace(
        /<script\b([^>]*?)src="([^"]+\.js)"([^>]*)><\/script>/g,
        (_tag, _before, src, _after) => {
          const js = fs.readFileSync(assetPath(src), 'utf8')
          return `<script type="module">\n${js}\n</script>`
        },
      )

      fs.writeFileSync(htmlPath, html)
      fs.rmSync(path.join(outDir, 'assets'), { recursive: true, force: true })
    },
  }
}

export default defineConfig({
  plugins: [inlineBuiltAssets()],
  build: {
    emptyOutDir: true,
    cssCodeSplit: false,
    rollupOptions: {
      output: {
        entryFileNames: 'assets/app.js',
        chunkFileNames: 'assets/[name].js',
        assetFileNames: 'assets/[name][extname]',
      },
    },
  },
})
