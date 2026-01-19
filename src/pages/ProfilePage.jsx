import { motion } from 'framer-motion';
import { useNavigate, Link } from 'react-router-dom';
import { User, LogOut, BookOpen, Settings } from 'lucide-react';
import { useAuth } from '../context/AuthContext';
import { useLanguage } from '../context/LanguageContext';
import PresetCard from '../components/features/PresetCard';
import '../styles/ProfilePage.css';

const MOCK_HISTORY = [
    { id: '1', title: 'Pesto Pasta', time: '15 min', difficulty: 'Easy', image: '' },
    { id: '2', title: 'Grilled Salmon', time: '30 min', difficulty: 'Medium', image: '' },
];

const ProfilePage = () => {
    const navigate = useNavigate();
    const { user, logout } = useAuth();
    const { t } = useLanguage();

    const handleLogout = () => {
        logout();
        navigate('/');
    };

    return (
        <div className="profile-container container">
            <div className="profile-nav">
                <Link to="/settings" className="nav-btn glass-panel">
                    <Settings size={20} />
                </Link>
            </div>
            <div className="profile-header glass-panel">
                <div className="user-info">
                    <div className="avatar">
                        {user?.photoUrl ? (
                            <img src={user.photoUrl} alt={user.name || 'User'} />
                        ) : (
                            <User size={40} />
                        )}
                    </div>
                    <div className="details">
                        <h2>{user?.name || 'Chef'}</h2>
                        <p>{user?.email || 'Master of the Kitchen'}</p>
                    </div>
                </div>
                <button className="logout-btn" onClick={handleLogout}>
                    <LogOut size={20} />
                    {t('logout')}
                </button>
            </div>

            <div className="history-section">
                <div className="section-header">
                    <h3><BookOpen size={20} /> {t('savedRecipes')}</h3>
                    <Link to="/saved" className="view-all-link">
                        {t('viewAll')}
                    </Link>
                </div>
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
