import React from 'react';
import { motion } from 'framer-motion';
import PresetCard from '../components/features/PresetCard';
import '../styles/HomePage.css';

const PRESETS = [
    { id: 'spaghetti', title: 'Classic Spaghetti', time: '20 min', difficulty: 'Easy', image: '' },
    { id: 'soup', title: 'Clear Soup', time: '30 min', difficulty: 'Medium', image: '' },
    { id: 'salad', title: 'Fresh Salad', time: '10 min', difficulty: 'Easy', image: '' },
    { id: 'chicken', title: 'Roast Chicken', time: '45 min', difficulty: 'Hard', image: '' },
];

const HomePage = () => {
    return (
        <div className="home-container container">
            <header className="home-header">
                <h1 className="text-gradient">Quick Menu</h1>
                <p className="subtitle">Choose a classic or create your own.</p>
            </header>

            <div className="presets-grid">
                {PRESETS.map((dish, index) => (
                    <motion.div
                        key={dish.id}
                        initial={{ opacity: 0, scale: 0.9 }}
                        animate={{ opacity: 1, scale: 1 }}
                        transition={{ delay: index * 0.1 }}
                    >
                        <PresetCard {...dish} />
                    </motion.div>
                ))}
            </div>
        </div>
    );
};

export default HomePage;
