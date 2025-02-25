import { defineConfig } from '@rsbuild/core';
import { pluginReact } from '@rsbuild/plugin-react';
import { pluginModuleFederation } from '@module-federation/rsbuild-plugin';
import { pluginTypeCheck } from "@rsbuild/plugin-type-check";

const cdn_url = process.env.CDN_URL;

export default defineConfig({
  output: {
    assetPrefix: cdn_url ? `${cdn_url}/payments` : undefined,
  },
  plugins: [
    pluginModuleFederation({
      name: "payments",
      exposes: {
        './Payments': './src/Payments.tsx'
      },
      shared: {
        "react": {
          singleton: true,
        },
        "react-dom": {
          singleton: true,
        },
        "ramda": {
          singleton: true,
        }
      }
    }),
    pluginTypeCheck(),
    pluginReact(),
  ],
  server: {
    port: 3001,
    base: '/payments',
  },
});
