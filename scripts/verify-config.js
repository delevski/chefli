#!/usr/bin/env node

/**
 * Configuration Verification Script
 * 
 * Verifies that backend and webapp are properly configured and can connect.
 */

import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

const BACKEND_URL = process.env.VITE_BACKEND_URL || 'http://localhost:3000';
const REQUIRED_ENV_VARS = {
  webapp: ['VITE_BACKEND_URL'],
  backend: ['INSTANTDB_ADMIN_TOKEN']
};

let errors = [];
let warnings = [];

console.log('🔍 Verifying Backend and Webapp Configuration...\n');

// Check environment variables
console.log('📋 Checking Environment Variables...');
const envExamplePath = join(__dirname, '../.env.example');
try {
  const envExample = readFileSync(envExamplePath, 'utf-8');
  console.log('✅ .env.example file found');
} catch (error) {
  warnings.push('.env.example file not found');
}

// Check backend URL
console.log(`\n🌐 Backend URL: ${BACKEND_URL}`);

// Check if backend is accessible
console.log('\n🔌 Testing Backend Connection...');
try {
  const response = await fetch(`${BACKEND_URL}/health`);
  if (response.ok) {
    const data = await response.json();
    console.log('✅ Backend is accessible');
    console.log(`   Status: ${data.status}`);
    console.log(`   Message: ${data.message}`);
  } else {
    errors.push(`Backend health check failed: ${response.status} ${response.statusText}`);
  }
} catch (error) {
  warnings.push(`Backend not accessible at ${BACKEND_URL}`);
  console.log(`⚠️  Backend not accessible: ${error.message}`);
  console.log('   Make sure the backend server is running: npm run dev:backend');
}

// Check API endpoints
console.log('\n📡 Testing API Endpoints...');
const endpoints = [
  '/api/users/create',
  '/api/users/find',
  '/api/users/find-google',
  '/api/users/create-google',
  '/api/recipes/generate'
];

for (const endpoint of endpoints) {
  try {
    const response = await fetch(`${BACKEND_URL}${endpoint}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({})
    });
    // We expect 400 or 500 errors for empty requests, but not 404
    if (response.status === 404) {
      errors.push(`Endpoint ${endpoint} not found (404)`);
    } else {
      console.log(`✅ ${endpoint} - accessible (${response.status})`);
    }
  } catch (error) {
    warnings.push(`Cannot reach ${endpoint}: ${error.message}`);
  }
}

// Check package.json scripts
console.log('\n📦 Checking Package Scripts...');
try {
  const packageJsonPath = join(__dirname, '../package.json');
  const packageJson = JSON.parse(readFileSync(packageJsonPath, 'utf-8'));
  const scripts = packageJson.scripts || {};
  
  const requiredScripts = ['dev:all', 'dev:backend', 'dev:webapp', 'build'];
  for (const script of requiredScripts) {
    if (scripts[script]) {
      console.log(`✅ Script '${script}' found`);
    } else {
      errors.push(`Required script '${script}' not found in package.json`);
    }
  }
} catch (error) {
  errors.push(`Cannot read package.json: ${error.message}`);
}

// Check vite.config.js
console.log('\n⚙️  Checking Vite Configuration...');
try {
  const viteConfigPath = join(__dirname, '../vite.config.js');
  const viteConfig = readFileSync(viteConfigPath, 'utf-8');
  if (viteConfig.includes('proxy')) {
    console.log('✅ Vite proxy configuration found');
  } else {
    warnings.push('Vite proxy configuration not found');
  }
} catch (error) {
  warnings.push(`Cannot read vite.config.js: ${error.message}`);
}

// Summary
console.log('\n' + '='.repeat(50));
console.log('📊 Verification Summary');
console.log('='.repeat(50));

if (errors.length === 0 && warnings.length === 0) {
  console.log('✅ All checks passed! Configuration looks good.');
  process.exit(0);
} else {
  if (errors.length > 0) {
    console.log(`\n❌ Errors (${errors.length}):`);
    errors.forEach((error, i) => console.log(`   ${i + 1}. ${error}`));
  }
  
  if (warnings.length > 0) {
    console.log(`\n⚠️  Warnings (${warnings.length}):`);
    warnings.forEach((warning, i) => console.log(`   ${i + 1}. ${warning}`));
  }
  
  console.log('\n💡 Next Steps:');
  console.log('   1. Make sure backend is running: npm run dev:backend');
  console.log('   2. Check environment variables in .env.development or .env.production');
  console.log('   3. Run both services together: npm run dev:all');
  
  process.exit(errors.length > 0 ? 1 : 0);
}
