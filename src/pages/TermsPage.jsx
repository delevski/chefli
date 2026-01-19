import { useNavigate } from 'react-router-dom';
import { motion } from 'framer-motion';
import { ChevronLeft, FileText } from 'lucide-react';
import { useLanguage } from '../context/LanguageContext';
import '../styles/TermsPage.css';

const TermsPage = () => {
  const navigate = useNavigate();
  const { t, isRTL } = useLanguage();

  return (
    <div className="terms-container container">
      <div className="terms-header">
        <button className="back-btn glass-panel" onClick={() => navigate(-1)}>
          <ChevronLeft size={24} />
        </button>
        <div className="header-content">
          <FileText size={32} className="header-icon" />
          <h1 className="text-gradient">{t('termsAndConditions')}</h1>
        </div>
      </div>

      <motion.div
        className="terms-content glass-panel"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.4 }}
      >
        <div className="content-section">
          <h2>{t('lastUpdated')}: {new Date().toLocaleDateString()}</h2>
          
          <section>
            <h3>1. {t('acceptanceOfTerms')}</h3>
            <p>
              {t('termsInfo1')}
            </p>
          </section>

          <section>
            <h3>2. {t('useOfService')}</h3>
            <p>
              {t('termsInfo2')}
            </p>
          </section>

          <section>
            <h3>3. {t('userAccounts')}</h3>
            <p>
              {t('termsInfo3')}
            </p>
          </section>

          <section>
            <h3>4. {t('intellectualProperty')}</h3>
            <p>
              {t('termsInfo4')}
            </p>
          </section>

          <section>
            <h3>5. {t('limitationOfLiability')}</h3>
            <p>
              {t('termsInfo5')}
            </p>
          </section>

          <section>
            <h3>6. {t('changesToTerms')}</h3>
            <p>
              {t('termsInfo6')}
            </p>
          </section>
        </div>
      </motion.div>
    </div>
  );
};

export default TermsPage;
