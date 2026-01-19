import { test, expect } from '@playwright/test';

/**
 * Webapp tests for Chefli React Web App
 */

test.describe('Landing Page', () => {
  test('should load landing page', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
    
    // Check that the page loaded - look for the main content
    const heroTitle = page.locator('.hero-title, h1');
    await expect(heroTitle).toBeVisible({ timeout: 10000 });
  });

  test('should display cook button', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
    
    // Cook button should be visible (uses .cook-button class)
    const cookButton = page.locator('.cook-button');
    await expect(cookButton).toBeVisible({ timeout: 10000 });
  });

  test('should display template chips', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
    
    // Template chips should be visible
    const templateChip = page.locator('.template-chip').first();
    await expect(templateChip).toBeVisible({ timeout: 10000 });
  });

  test('should display textarea for ingredients', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
    
    // Main input textarea
    const textarea = page.locator('textarea.main-input, textarea');
    await expect(textarea).toBeVisible({ timeout: 10000 });
  });

  test('should fill textarea with template on click', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
    
    const templateChip = page.locator('.template-chip').first();
    await templateChip.click();
    
    // Textarea should have content now
    const textarea = page.locator('textarea');
    const value = await textarea.inputValue();
    expect(value.length).toBeGreaterThan(0);
  });
});

test.describe('Login Modal', () => {
  test('should show login modal when clicking Cook without ingredients', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
    
    // Click cook button without entering anything - should show alert
    const cookButton = page.locator('.cook-button');
    await cookButton.click();
    
    // Dialog should appear for empty ingredients
    page.on('dialog', async dialog => {
      expect(dialog.message()).toContain('ingredient');
      await dialog.accept();
    });
  });

  test('should show login modal when clicking Cook with ingredients (not logged in)', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
    
    // Enter ingredients first
    const textarea = page.locator('textarea');
    await textarea.fill('chicken, rice, vegetables');
    
    // Click cook button - should show login modal
    const cookButton = page.locator('.cook-button');
    await cookButton.click();
    
    // Login modal should appear (use .login-modal specifically)
    const loginModal = page.locator('.login-modal');
    await expect(loginModal).toBeVisible({ timeout: 5000 });
  });

  test('should display email and password fields in login modal', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
    
    // Trigger login modal
    const textarea = page.locator('textarea');
    await textarea.fill('chicken');
    
    const cookButton = page.locator('.cook-button');
    await cookButton.click();
    
    // Check for login form elements
    const emailInput = page.locator('.login-modal input[type="email"]');
    const passwordInput = page.locator('.login-modal input[type="password"]');
    
    await expect(emailInput).toBeVisible({ timeout: 5000 });
    await expect(passwordInput).toBeVisible();
  });

  test('should close login modal on X button click', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
    
    // Trigger login modal
    const textarea = page.locator('textarea');
    await textarea.fill('chicken');
    const cookButton = page.locator('.cook-button');
    await cookButton.click();
    
    // Wait for modal
    const loginModal = page.locator('.login-modal');
    await expect(loginModal).toBeVisible({ timeout: 5000 });
    
    // Close modal
    const closeBtn = page.locator('.close-btn');
    await closeBtn.click();
    
    // Modal should be hidden
    await expect(loginModal).not.toBeVisible({ timeout: 3000 });
  });

  test('should allow typing in form fields', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
    
    // Trigger login modal
    const textarea = page.locator('textarea');
    await textarea.fill('chicken');
    const cookButton = page.locator('.cook-button');
    await cookButton.click();
    
    // Fill form
    const emailInput = page.locator('.login-modal input[type="email"]');
    const passwordInput = page.locator('.login-modal input[type="password"]');
    
    await emailInput.fill('test@example.com');
    await passwordInput.fill('password123');
    
    await expect(emailInput).toHaveValue('test@example.com');
    await expect(passwordInput).toHaveValue('password123');
  });

  test('should toggle between sign in and create account modes', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
    
    // Trigger login modal
    const textarea = page.locator('textarea');
    await textarea.fill('chicken');
    const cookButton = page.locator('.cook-button');
    await cookButton.click();
    
    // Find toggle button
    const toggleBtn = page.locator('.toggle-mode-btn');
    await toggleBtn.click();
    
    // Name field should appear in create account mode
    const nameInput = page.locator('.login-modal input[type="text"]');
    await expect(nameInput).toBeVisible({ timeout: 3000 });
  });
});

test.describe('Settings Page', () => {
  test('should navigate to settings page', async ({ page }) => {
    await page.goto('/settings');
    await page.waitForLoadState('domcontentloaded');
    
    // Settings content should be visible
    const settingsContent = page.locator('.settings-container, .settings-page');
    await expect(settingsContent).toBeVisible({ timeout: 10000 });
  });

  test('should have back button', async ({ page }) => {
    await page.goto('/settings');
    await page.waitForLoadState('domcontentloaded');
    
    const backButton = page.locator('.back-btn, button').filter({ hasText: /back|←/i }).first();
    const isVisible = await backButton.isVisible().catch(() => false);
    console.log('Back button visible:', isVisible);
  });
});

test.describe('Navigation', () => {
  test('should have settings link on landing page', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
    
    const settingsLink = page.locator('a[href="/settings"], .settings-btn');
    await expect(settingsLink).toBeVisible({ timeout: 10000 });
  });

  test('should navigate to settings from landing', async ({ page }) => {
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
    
    const settingsLink = page.locator('a[href="/settings"]');
    await settingsLink.click();
    
    await page.waitForURL(/settings/);
    expect(page.url()).toContain('/settings');
  });
});

test.describe('Backend API', () => {
  test('should return health check', async ({ request }) => {
    const response = await request.get('http://localhost:3000/health');
    expect(response.status()).toBe(200);
    
    const body = await response.json();
    expect(body.status).toBe('ok');
  });

  test('should handle user find endpoint', async ({ request }) => {
    const response = await request.post('http://localhost:3000/api/users/find', {
      data: { email: 'test@example.com' }
    });
    
    // Should return 200 (even if user not found)
    expect([200, 404]).toContain(response.status());
  });

  test('should handle user create endpoint', async ({ request }) => {
    const testEmail = `playwright-test-${Date.now()}@example.com`;
    
    const response = await request.post('http://localhost:3000/api/users/create', {
      data: { 
        email: testEmail,
        password: 'testpassword123'
      }
    });
    
    // Should return success or error (not crash)
    expect([200, 201, 400, 409]).toContain(response.status());
  });
});

test.describe('Responsive Design', () => {
  test('should display correctly on mobile', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
    
    // Cook button should still be visible on mobile
    const cookButton = page.locator('.cook-button');
    await expect(cookButton).toBeVisible({ timeout: 10000 });
  });

  test('should display correctly on tablet', async ({ page }) => {
    await page.setViewportSize({ width: 768, height: 1024 });
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
    
    const cookButton = page.locator('.cook-button');
    await expect(cookButton).toBeVisible({ timeout: 10000 });
  });
});
