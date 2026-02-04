#!/usr/bin/env node

import sharp from 'sharp';
import { promises as fs } from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PUBLIC_DIR = path.join(__dirname, 'public', 'images');
const LOGO_FILE = 'techresona-logo.png';

async function optimizeLogo() {
  console.log('🎨 Optimizing TechResona logo images...\n');
  
  const inputPath = path.join(PUBLIC_DIR, LOGO_FILE);
  
  try {
    // Check if file exists
    await fs.access(inputPath);
    
    // Get original file stats
    const originalStats = await fs.stat(inputPath);
    console.log(`📊 Original file: ${(originalStats.size / 1024).toFixed(2)} KB`);
    
    // Generate optimized PNG (for logo - needs transparency)
    const optimizedPngPath = path.join(PUBLIC_DIR, 'techresona-logo-optimized.png');
    await sharp(inputPath)
      .resize(200, 48, {
        fit: 'contain',
        background: { r: 0, g: 0, b: 0, alpha: 0 }
      })
      .png({ quality: 90, compressionLevel: 9 })
      .toFile(optimizedPngPath);
    
    const pngStats = await fs.stat(optimizedPngPath);
    console.log(`✅ Optimized PNG: ${(pngStats.size / 1024).toFixed(2)} KB (${((1 - pngStats.size / originalStats.size) * 100).toFixed(1)}% smaller)`);
    
    // Generate WebP version (better compression)
    const webpPath = path.join(PUBLIC_DIR, 'techresona-logo.webp');
    await sharp(inputPath)
      .resize(200, 48, {
        fit: 'contain',
        background: { r: 0, g: 0, b: 0, alpha: 0 }
      })
      .webp({ quality: 90 })
      .toFile(webpPath);
    
    const webpStats = await fs.stat(webpPath);
    console.log(`✅ WebP version: ${(webpStats.size / 1024).toFixed(2)} KB (${((1 - webpStats.size / originalStats.size) * 100).toFixed(1)}% smaller)`);
    
    // Generate AVIF version (best compression)
    const avifPath = path.join(PUBLIC_DIR, 'techresona-logo.avif');
    await sharp(inputPath)
      .resize(200, 48, {
        fit: 'contain',
        background: { r: 0, g: 0, b: 0, alpha: 0 }
      })
      .avif({ quality: 80 })
      .toFile(avifPath);
    
    const avifStats = await fs.stat(avifPath);
    console.log(`✅ AVIF version: ${(avifStats.size / 1024).toFixed(2)} KB (${((1 - avifStats.size / originalStats.size) * 100).toFixed(1)}% smaller)`);
    
    // Generate 2x retina versions
    const webp2xPath = path.join(PUBLIC_DIR, 'techresona-logo@2x.webp');
    await sharp(inputPath)
      .resize(400, 96, {
        fit: 'contain',
        background: { r: 0, g: 0, b: 0, alpha: 0 }
      })
      .webp({ quality: 90 })
      .toFile(webp2xPath);
    
    const webp2xStats = await fs.stat(webp2xPath);
    console.log(`✅ WebP 2x: ${(webp2xStats.size / 1024).toFixed(2)} KB (for retina displays)`);
    
    console.log('\n🎉 Image optimization complete!');
    console.log(`💾 Total savings: ${((originalStats.size - webpStats.size) / 1024).toFixed(2)} KB (using WebP)`);
    
  } catch (error) {
    console.error('❌ Error optimizing images:', error.message);
    process.exit(1);
  }
}

optimizeLogo();
