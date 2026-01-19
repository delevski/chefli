import { motion } from 'framer-motion';
import { Clock, TrendingUp } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import '../../styles/HomePage.css'; // We'll create this next

const PresetCard = ({ title, image, time, difficulty, id }) => {
    const navigate = useNavigate();

    return (
        <motion.div
            className="preset-card glass-panel"
            whileHover={{ y: -5, boxShadow: '0 10px 30px -10px rgba(0,0,0,0.5)' }}
            onClick={() => navigate(`/recipe/${id}`)}
        >
            <div className="card-image-placeholder" style={{ backgroundImage: `url(${image})` }}>
                {/* Fallback or gradient if no image */}
                {!image && <span className="emoji-icon">🍳</span>}
            </div>

            <div className="card-content">
                <h3>{title}</h3>
                <div className="card-meta">
                    <span className="meta-item"><Clock size={14} /> {time}</span>
                    <span className="meta-item"><TrendingUp size={14} /> {difficulty}</span>
                </div>
            </div>
        </motion.div>
    );
};

export default PresetCard;
