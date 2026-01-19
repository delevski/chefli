import { motion } from 'framer-motion';
import { User, LogOut, BookOpen } from 'lucide-react';
import PresetCard from '../components/features/PresetCard';
import '../styles/ProfilePage.css';

const MOCK_HISTORY = [
    { id: '1', title: 'Pesto Pasta', time: '15 min', difficulty: 'Easy', image: '' },
    { id: '2', title: 'Grilled Salmon', time: '30 min', difficulty: 'Medium', image: '' },
];

const ProfilePage = () => {
    return (
        <div className="profile-container container">
            <div className="profile-header glass-panel">
                <div className="user-info">
                    <div className="avatar">
                        <User size={40} />
                    </div>
                    <div className="details">
                        <h2>Chef John Doe</h2>
                        <p>Master of the Kitchen</p>
                    </div>
                </div>
                <button className="logout-btn">
                    <LogOut size={20} />
                    Logout
                </button>
            </div>

            <div className="history-section">
                <h3><BookOpen size={20} /> Recipe History</h3>
                <div className="history-grid">
                    {MOCK_HISTORY.map(dish => (
                        <div key={dish.id} className="history-item-wrapper">
                            <PresetCard {...dish} />
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
};

export default ProfilePage;
