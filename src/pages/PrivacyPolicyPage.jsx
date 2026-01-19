import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { ChevronLeft, Shield } from 'lucide-react';
import { useLanguage } from '../context/LanguageContext';
import '../styles/PrivacyPolicyPage.css';

const PrivacyPolicyPage = () => {
  const navigate = useNavigate();
  const { t, isRTL } = useLanguage();

  return (
    <div className="privacy-policy-container container">
      <div className="privacy-header">
        <button className="back-btn glass-panel" onClick={() => navigate(-1)}>
          <ChevronLeft size={24} />
        </button>
        <div className="header-content">
          <Shield size={32} className="header-icon" />
          <h1 className="text-gradient">{t('privacyPolicy')}</h1>
        </div>
      </div>

      <motion.div
        className="privacy-content glass-panel"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4 }}
      >
        <div className="content-section">
          <h2>{t('lastUpdated')}: {new Date().toLocaleDateString()}</h2>
          
          <section>
            <h3>1. {t('informationWeCollect')}</h3>
            <p>
              {t('privacyInfo1')}
            </p>
          </section>

          <section>
            <h3>2. {t('howWeUseYourInformation')}</h3>
            <p>
              {t('privacyInfo2')}
            </p>
          </section>

          <section>
            <h3>3. {t('dataSecurity')}</h3>
            <p>
              {t('privacyInfo3')}
            </p>
          </section>

          <section>
            <h3>4. {t('yourRights')}</h3>
            <p>
              {t('privacyInfo4')}
            </p>
          </section>

          <section>
            <h3>5. {t('contactUs')}</h3>
            <p>
              {t('privacyInfo5')}
            </p>
          </section>
        </div>
      </motion.div>
    </div>
  );
};

export default PrivacyPolicyPage;
