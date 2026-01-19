import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import { LanguageProvider } from './context/LanguageContext';
import { RecipeProvider } from './context/RecipeContext';
import ErrorBoundary from './components/ErrorBoundary';
import LandingPage from './pages/LandingPage';
import HomePage from './pages/HomePage';
import RecipePage from './pages/RecipePage';
import ProfilePage from './pages/ProfilePage';

function App() {
  return (
    <ErrorBoundary>
      <LanguageProvider>
        <AuthProvider>
          <ErrorBoundary>
            <RecipeProvider>
              <Router>
                <div className="app-container">
                  <Routes>
                    <Route path="/" element={<LandingPage />} />
                    <Route path="/home" element={<HomePage />} />
                    <Route path="/recipe/:id" element={<RecipePage />} />
                    <Route path="/profile" element={<ProfilePage />} />
                  </Routes>
                </div>
              </Router>
            </RecipeProvider>
          </ErrorBoundary>
        </AuthProvider>
      </LanguageProvider>
    </ErrorBoundary>
  );
}

export default App;
