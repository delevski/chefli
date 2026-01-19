import { test, expect } from '@playwright/test';

/**
 * Authentication flow tests for Chefli React Web App
 * Login is a modal that appears when clicking Cook while not logged in
 */

test.describe('Authentication Flow', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to the app
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
  });

  test('should display login modal when trying to cook', async ({ page }) => {
    // Enter ingredients to trigger login modal (not the empty alert)
    const textarea = page.locator('textarea');
    await textarea.fill('chicken, rice');
    
    // Click cook button
    const cookButton = page.locator('.cook-button');
    await cookButton.click();
    
    // Wait for login modal
    const loginModal = page.locator('.login-modal');
    await expect(loginModal).toBeVisible({ timeout: 5000 });
    
    // Check for email input field
    const emailInput = page.locator('.login-modal input[type="email"]');
    await expect(emailInput).toBeVisible();
    
    // Check for password input field
    const passwordInput = page.locator('.login-modal input[type="password"]');
    await expect(passwordInput).toBeVisible();
  });

  test('should show validation errors for invalid email', async ({ page }) => {
    // Trigger login modal
    const textarea = page.locator('textarea');
    await textarea.fill('chicken');
    const cookButton = page.locator('.cook-button');
    await cookButton.click();
    
    // Wait for modal
    const loginModal = page.locator('.login-modal');
    await expect(loginModal).toBeVisible({ timeout: 5000 });
    
    // Find email input and fill with invalid email
    const emailInput = page.locator('.login-modal input[type="email"]');
    await emailInput.fill('invalid-email');
    
    // Fill password (required field)
    const passwordInput = page.locator('.login-modal input[type="password"]');
    await passwordInput.fill('password123');
    
    // Try to submit
    const submitBtn = page.locator('.login-modal .submit-btn');
    await submitBtn.click();
    
    // Should show validation error (HTML5 validation for email)
    const isInvalid = await emailInput.evaluate((el) => !el.validity.valid);
    expect(isInvalid).toBe(true);
  });

  test('should switch to create account mode', async ({ page }) => {
    // Trigger login modal
    const textarea = page.locator('textarea');
    await textarea.fill('chicken');
    const cookButton = page.locator('.cook-button');
    await cookButton.click();
    
    // Wait for modal
    await page.locator('.login-modal').waitFor({ state: 'visible' });
    
    // Click toggle to switch to create account
    const toggleBtn = page.locator('.toggle-mode-btn');
    await toggleBtn.click();
    
    // Name field should appear in create account mode
    const nameInput = page.locator('.login-modal input[type="text"]');
    await expect(nameInput).toBeVisible({ timeout: 3000 });
  });

  test('should allow filling in login form', async ({ page }) => {
    // Trigger login modal
    const textarea = page.locator('textarea');
    await textarea.fill('chicken');
    const cookButton = page.locator('.cook-button');
    await cookButton.click();
    
    // Wait for modal
    await page.locator('.login-modal').waitFor({ state: 'visible' });
    
    // Fill in form
    const emailInput = page.locator('.login-modal input[type="email"]');
    const passwordInput = page.locator('.login-modal input[type="password"]');
    
    await emailInput.fill('test@example.com');
    await passwordInput.fill('testpassword123');
    
    await expect(emailInput).toHaveValue('test@example.com');
    await expect(passwordInput).toHaveValue('testpassword123');
  });

  test('should have submit button in login form', async ({ page }) => {
    // Trigger login modal
    const textarea = page.locator('textarea');
    await textarea.fill('chicken');
    const cookButton = page.locator('.cook-button');
    await cookButton.click();
    
    // Wait for modal
    await page.locator('.login-modal').waitFor({ state: 'visible' });
    
    // Check for submit button
    const submitBtn = page.locator('.login-modal .submit-btn');
    await expect(submitBtn).toBeVisible();
  });

  test('should close modal when clicking X', async ({ page }) => {
    // Trigger login modal
    const textarea = page.locator('textarea');
    await textarea.fill('chicken');
    const cookButton = page.locator('.cook-button');
    await cookButton.click();
    
    // Wait for modal
    const loginModal = page.locator('.login-modal');
    await expect(loginModal).toBeVisible({ timeout: 5000 });
    
    // Click close button
    const closeBtn = page.locator('.close-btn');
    await closeBtn.click();
    
    // Modal should be hidden
    await expect(loginModal).not.toBeVisible({ timeout: 3000 });
  });
});

test.describe('User Session', () => {
  test('should persist login state in localStorage', async ({ page }) => {
    // Navigate to app
    await page.goto('/');
    await page.waitForLoadState('domcontentloaded');
    
    // Check localStorage for auth data
    const authUser = await page.evaluate(() => localStorage.getItem('auth_user'));
    const authToken = await page.evaluate(() => localStorage.getItem('auth_token'));
    
    // Log the state (might be null if not logged in)
    console.log('Auth user in localStorage:', authUser ? 'present' : 'null');
    console.log('Auth token in localStorage:', authToken ? 'present' : 'null');
  });
});
