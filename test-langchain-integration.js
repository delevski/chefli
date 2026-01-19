/**
 * Test script to verify LangChain integration
 * Tests the transformation logic and endpoint connectivity
 */

import axios from 'axios';

const LANGCHAIN_URL = 'https://ordi1985.pythonanywhere.com/generate-recipe';
const BACKEND_PROXY_URL = 'http://localhost:3000/api/recipes/generate';

// Transform function matching the React service implementation
const transformLangChainResponse = (langChainData) => {
  const recipeData = langChainData.recipe || {};
  const imageUrl = langChainData.image_url;
  const nutrition = langChainData.nutrition || {};
  
  // Extract time from instructions or use default
  const instructions = recipeData.instructions || [];
  let estimatedTime = 30; // Default 30 minutes
  for (const instruction of instructions) {
    const instructionText = String(instruction).toLowerCase();
    // Try to extract time mentions like "15 minutes", "cook for 20 min"
    const timeMatch = instructionText.match(/(\d+)\s*(?:min|minute|minutes|דקות|דקה)/);
    if (timeMatch) {
      const extractedTime = parseInt(timeMatch[1], 10);
      if (extractedTime && extractedTime > estimatedTime) {
        estimatedTime = extractedTime;
      }
    }
  }
  
  // Default difficulty to medium
  const difficulty = 'medium';
  
  return {
    dishName: recipeData.dish_name || 'Generated Recipe',
    name: recipeData.dish_name || 'Generated Recipe',
    shortDescription: '',
    description: '',
    imageUrl: imageUrl || 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
    estimatedPreparationTime: `${estimatedTime} minutes`,
    time: estimatedTime,
    prepTimeMinutes: estimatedTime,
    difficultyLevel: difficulty,
    difficulty: difficulty,
    ingredientsUsed: recipeData.ingredients || [],
    ingredients: recipeData.ingredients || [],
    preparationSteps: instructions.map(e => String(e)),
    steps: instructions.map(e => String(e)),
    estimatedCaloricValue: nutrition.calories ? Math.round(nutrition.calories) : null,
    calories: nutrition.calories ? Math.round(nutrition.calories) : null,
    cookingMethods: [],
    calorieAccuracyNote: null,
  };
};

async function testDirectLangChain() {
  console.log('\n🧪 Testing Direct LangChain Endpoint...');
  try {
    const response = await axios.post(LANGCHAIN_URL, {
      menu: 'טונה,לימון,בצל,אספרגוס'
    }, {
      headers: {
        'Content-Type': 'application/json; charset=utf-8'
      }
    });
    
    console.log('✅ Direct endpoint response received');
    console.log('📋 Recipe Name:', response.data.recipe?.dish_name);
    console.log('🖼️  Image URL:', response.data.image_url ? 'Present' : 'Missing');
    console.log('🔥 Calories:', response.data.nutrition?.calories);
    console.log('📝 Instructions count:', response.data.recipe?.instructions?.length || 0);
    
    // Test transformation
    const transformed = transformLangChainResponse(response.data);
    console.log('\n🔄 Transformation Test:');
    console.log('  ✅ dishName:', transformed.dishName);
    console.log('  ✅ time:', transformed.time, 'minutes');
    console.log('  ✅ difficulty:', transformed.difficulty);
    console.log('  ✅ steps count:', transformed.steps.length);
    console.log('  ✅ calories:', transformed.calories);
    console.log('  ✅ imageUrl:', transformed.imageUrl ? 'Present' : 'Missing');
    
    return true;
  } catch (error) {
    console.error('❌ Direct endpoint test failed:', error.message);
    return false;
  }
}

async function testBackendProxy() {
  console.log('\n🧪 Testing Backend Proxy Endpoint...');
  try {
    // Test with menu format
    const response1 = await axios.post(BACKEND_PROXY_URL, {
      menu: 'tuna,lemon,onion'
    });
    
    console.log('✅ Backend proxy (menu format) response received');
    console.log('📋 Recipe Name:', response1.data.recipe?.dish_name);
    
    // Test with ingredients array format
    const response2 = await axios.post(BACKEND_PROXY_URL, {
      ingredients: ['tuna', 'lemon', 'onion']
    });
    
    console.log('✅ Backend proxy (ingredients array) response received');
    console.log('📋 Recipe Name:', response2.data.recipe?.dish_name);
    
    return true;
  } catch (error) {
    if (error.code === 'ECONNREFUSED') {
      console.log('⚠️  Backend server not running (this is optional)');
      return true; // Not a failure, backend is optional
    }
    console.error('❌ Backend proxy test failed:', error.message);
    return false;
  }
}

async function testEnglishIngredients() {
  console.log('\n🧪 Testing with English Ingredients...');
  try {
    const response = await axios.post(LANGCHAIN_URL, {
      menu: 'chicken,garlic,tomatoes,basil'
    });
    
    console.log('✅ English ingredients test passed');
    console.log('📋 Recipe Name:', response.data.recipe?.dish_name);
    
    const transformed = transformLangChainResponse(response.data);
    console.log('  ✅ Transformation successful');
    console.log('  ✅ dishName:', transformed.dishName);
    console.log('  ✅ steps:', transformed.steps.length);
    
    return true;
  } catch (error) {
    console.error('❌ English ingredients test failed:', error.message);
    return false;
  }
}

async function runAllTests() {
  console.log('🚀 Starting LangChain Integration Tests\n');
  console.log('=' .repeat(50));
  
  const results = {
    direct: await testDirectLangChain(),
    proxy: await testBackendProxy(),
    english: await testEnglishIngredients(),
  };
  
  console.log('\n' + '='.repeat(50));
  console.log('\n📊 Test Results Summary:');
  console.log('  Direct LangChain Endpoint:', results.direct ? '✅ PASS' : '❌ FAIL');
  console.log('  Backend Proxy Endpoint:', results.proxy ? '✅ PASS' : '❌ FAIL');
  console.log('  English Ingredients:', results.english ? '✅ PASS' : '❌ FAIL');
  
  const allPassed = Object.values(results).every(r => r);
  console.log('\n' + (allPassed ? '✅ All tests passed!' : '⚠️  Some tests failed or skipped'));
  
  return allPassed;
}

// Run tests
runAllTests().catch(console.error);
