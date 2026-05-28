import { defineConfig } from 'vite'
import rabbita from '@rabbita/vite'
import fs from 'node:fs'
import path from 'node:path'
import { spawnSync } from 'node:child_process'

let generatedMoonModJson = false

function ensureMoonModJson() {
  // @rabbita/vite currently looks for moon.mod.json, while this repository
  // uses moon.mod. Keep the generated file local to this example build.
  if (fs.existsSync('moon.mod.json')) {
    if (!fs.existsSync('moon.mod')) {
      return
    }
    fs.rmSync('moon.mod.json')
  }
  generatedMoonModJson = true
  fs.writeFileSync(
    'moon.mod.json',
    `${JSON.stringify({
      name: 'shiguri-01/desktop-http-workbench-example',
      version: '0.1.0',
      deps: {
        'moonbitlang/async': '0.18.1',
        'moonbit-community/rabbita': '0.12.2',
        'shiguri-01/desktop': '0.1.0',
      },
      readme: 'README.mbt.md',
      repository: '',
      license: 'Apache-2.0',
      keywords: ['desktop', 'http', 'rabbita', 'vite'],
      description: 'HTTP/API Workbench desktop example for shiguri-01/desktop',
      source: 'src',
      'preferred-target': 'native',
      'supported-targets': 'js+native',
    }, null, 2)}\n`,
  )
}

ensureMoonModJson()

function ensureRabbitaBuildMetadata(root) {
  const result = spawnSync('moon', ['info', '--target', 'js'], {
    cwd: root,
    encoding: 'utf8',
  })
  if (result.status !== 0) {
    throw new Error((result.stdout ?? '') + (result.stderr ?? ''))
  }

  const buildRoot = path.join(root, '_build')
  const ideMetadata = path.join(buildRoot, '.ide', 'packages.json')
  const rabbitaMetadata = path.join(buildRoot, 'packages.json')
  if (!fs.existsSync(ideMetadata)) {
    throw new Error(`Cannot find MoonBit package metadata at ${ideMetadata}`)
  }
  fs.copyFileSync(ideMetadata, rabbitaMetadata)
}

function inlineBuiltAssets() {
  let outDir = 'dist'

  return {
    name: 'http-workbench-inline-built-assets',
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
  plugins: [
    {
      name: 'http-workbench-rabbita-metadata',
      enforce: 'pre',
      buildStart() {
        // @rabbita/vite reads _build/packages.json, while this nested example
        // workspace receives metadata under _build/.ide/packages.json.
        ensureRabbitaBuildMetadata(process.cwd())
      },
    },
    rabbita({ main: 'frontend' }),
    inlineBuiltAssets(),
    {
      name: 'http-workbench-cleanup-rabbita-compat',
      closeBundle() {
        if (generatedMoonModJson && fs.existsSync('moon.mod.json')) {
          fs.rmSync('moon.mod.json')
        }
      },
    },
  ],
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
