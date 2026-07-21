import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  server: {
    proxy: {
      '/api': {
        target: 'http://localhost:3000',
        changeOrigin: true
      }
    }
  },
  plugins: [
    react(),
    {
      name: 'configure-wasm-mime',
      configureServer(server) {
        server.middlewares.use((req, res, next) => {
          if (req.url && req.url.endsWith('.wasm')) {
            res.setHeader('Content-Type', 'application/wasm');
          }
          next();
        });
      }
    }
  ],
})
