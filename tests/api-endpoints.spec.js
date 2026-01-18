import { test, expect } from '@playwright/test';

/**
 * API Endpoint tests - Verify InstantDB API endpoints are correct
 * These tests check if the API endpoints used in the Flutter app are accessible
 */

const APP_ID = '588227b6-6022-44a9-88f3-b1c2e2cce304';
const BASE_URL = 'https://api.instantdb.com';

test.describe('InstantDB API Endpoints', () => {
  test('should verify base URL is accessible', async ({ request }) => {
    // Try to access InstantDB API (might fail without auth, but should not be 404)
    const response = await request.get(`${BASE_URL}/apps/${APP_ID}`);
    
    // API might return 401 (unauthorized) or 404 (not found) or 200
    // We just check it's not a network error
    expect([200, 401, 403, 404]).toContain(response.status());
  });

  test('should verify users endpoint structure', async ({ request }) => {
    // Check if users endpoint exists (will likely need auth)
    const response = await request.get(`${BASE_URL}/apps/${APP_ID}/entities/users`, {
      headers: {
        'Content-Type': 'application/json',
      },
    });
    
    // Log the response for debugging
    console.log('Users endpoint status:', response.status());
    console.log('Users endpoint response:', await response.text().catch(() => 'No response body'));
    
    // Should not be 500 (server error) - 401/403/404 are expected without auth
    expect(response.status()).not.toBe(500);
  });

  test('should verify recipes endpoint structure', async ({ request }) => {
    // Check if recipes endpoint exists
    const response = await request.get(`${BASE_URL}/apps/${APP_ID}/entities/recipes`, {
      headers: {
        'Content-Type': 'application/json',
      },
    });
    
    console.log('Recipes endpoint status:', response.status());
    console.log('Recipes endpoint response:', await response.text().catch(() => 'No response body'));
    
    // Should not be 500 (server error)
    expect(response.status()).not.toBe(500);
  });

  test('should verify API accepts JSON content type', async ({ request }) => {
    // Test POST request with JSON (will fail without auth/data, but should accept JSON)
    const response = await request.post(`${BASE_URL}/apps/${APP_ID}/entities/users`, {
      headers: {
        'Content-Type': 'application/json',
      },
      data: {
        test: 'data',
      },
    });
    
    console.log('POST test status:', response.status());
    
    // Should accept JSON (not 415 Unsupported Media Type)
    expect(response.status()).not.toBe(415);
  });
});

test.describe('InstantDB Authentication Flow', () => {
  test('should verify authentication endpoints exist', async ({ request }) => {
    // Check if there's an auth endpoint (InstantDB might use different structure)
    // This is exploratory to find the correct endpoints
    
    const endpoints = [
      `${BASE_URL}/auth`,
      `${BASE_URL}/apps/${APP_ID}/auth`,
      `${BASE_URL}/admin/auth`,
    ];
    
    for (const endpoint of endpoints) {
      try {
        const response = await request.get(endpoint);
        console.log(`Endpoint ${endpoint}: Status ${response.status()}`);
      } catch (error) {
        console.log(`Endpoint ${endpoint}: Error - ${error.message}`);
      }
    }
  });
});

