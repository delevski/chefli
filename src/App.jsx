import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { RecipeProvider } from './context/RecipeContext';
import LandingPage from './pages/LandingPage';
import HomePage from './pages/HomePage';
import RecipePage from './pages/RecipePage';
import ProfilePage from './pages/ProfilePage';

function App() {
  return (
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
  );
}

export default App;
