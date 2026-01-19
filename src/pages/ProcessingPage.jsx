import { useState, useEffect, useRef, Fragment } from 'react';
import { X, Utensils, Flame, Soup } from 'lucide-react';
import { motion, useAnimation, useMotionValue, useTransform } from 'framer-motion';
import { useLanguage } from '../context/LanguageContext';
import '../styles/ProcessingPage.css';

const ProcessingPage = ({ onComplete }) => {
  const [currentPhaseIndex, setCurrentPhaseIndex] = useState(0);
  const [currentQuoteIndex, setCurrentQuoteIndex] = useState(0);
  const [progress, setProgress] = useState(0);
  const { t, processingPhases, quotes, isRTL } = useLanguage();
  const progressRef = useRef(null);
  const quoteIntervalRef = useRef(null);
  const phaseIntervalRef = useRef(null);

  useEffect(() => {
    // Start progress animation (0 to 100% over 30 seconds)
    const duration = 30000; // 30 seconds
    const startTime = Date.now();
    const interval = setInterval(() => {
      const elapsed = Date.now() - startTime;
      const newProgress = Math.min((elapsed / duration) * 100, 100);
      setProgress(newProgress);

      // Update phase based on progress
      const phaseIndex = Math.floor((newProgress / 100) * processingPhases.length);
      if (phaseIndex < processingPhases.length) {
        setCurrentPhaseIndex(phaseIndex);
      }

      if (newProgress >= 100) {
        clearInterval(interval);
      }
    }, 100);

    // Cycle quotes every 4 seconds
    quoteIntervalRef.current = setInterval(() => {
      setCurrentQuoteIndex((prev) => (prev + 1) % quotes.length);
    }, 4000);

    return () => {
      clearInterval(interval);
      if (quoteIntervalRef.current) {
        clearInterval(quoteIntervalRef.current);
      }
      if (phaseIntervalRef.current) {
        clearInterval(phaseIntervalRef.current);
      }
    };
  }, [processingPhases.length, quotes.length]);

  const pulseAnimation = useAnimation();
  const rotateAnimation = useMotionValue(0);

  useEffect(() => {
    // Pulse animation
    pulseAnimation.start({
      scale: [1, 1.1, 1],
      opacity: [0.5, 1, 0.5],
      transition: {
        duration: 1.5,
        repeat: Infinity,
        ease: 'easeInOut',
      },
    });

    // Rotate animation
    const rotateInterval = setInterval(() => {
      rotateAnimation.set(rotateAnimation.get() + 0.01);
    }, 16);

    return () => clearInterval(rotateInterval);
  }, [pulseAnimation, rotateAnimation]);

  const outerRingRotation = useTransform(rotateAnimation, (value) => value * 360);
  const innerRingRotation = useTransform(rotateAnimation, (value) => -value * 360 * 0.7);

  return (
    <div className="processing-overlay">
      <div className="processing-container">
        {/* Header */}
        <div className="processing-header">
          <div className="processing-status">
            <motion.div
              className="processing-dot"
              animate={pulseAnimation}
            />
            <span>{t('processing')}</span>
          </div>
          <button className="close-btn" onClick={onComplete}>
            <X size={24} />
          </button>
        </div>

        {/* Main Content */}
        <div className="processing-content">
          {/* Animated Rings */}
          <div className="rings-container">
            {/* Outer glow */}
            <motion.div
              className="outer-glow"
              animate={{
                scale: [1, 1.1, 1],
                opacity: [0.15, 0.25, 0.15],
              }}
              transition={{
                duration: 1.5,
                repeat: Infinity,
                ease: 'easeInOut',
              }}
            />

            {/* Glass container */}
            <div className="glass-container" />

            {/* Outer rotating ring */}
            <motion.div
              className="ring outer-ring"
              style={{
                rotate: outerRingRotation,
              }}
            >
              <svg width="200" height="200" viewBox="0 0 200 200">
                <circle
                  cx="100"
                  cy="100"
                  r="90"
                  fill="none"
                  stroke="#FF6B35"
                  strokeWidth="3"
                  strokeDasharray={`${2 * Math.PI * 90 * 0.75} ${2 * Math.PI * 90}`}
                  strokeDashoffset={2 * Math.PI * 90 * 0.25}
                  strokeLinecap="round"
                />
              </svg>
            </motion.div>

            {/* Inner rotating ring */}
            <motion.div
              className="ring inner-ring"
              style={{
                rotate: innerRingRotation,
              }}
            >
              <svg width="160" height="160" viewBox="0 0 160 160">
                <circle
                  cx="80"
                  cy="80"
                  r="70"
                  fill="none"
                  stroke="#4ECDC4"
                  strokeWidth="2"
                  strokeDasharray={`${2 * Math.PI * 70 * 0.6} ${2 * Math.PI * 70}`}
                  strokeDashoffset={2 * Math.PI * 70 * 0.4}
                  strokeLinecap="round"
                  opacity="0.6"
                />
              </svg>
            </motion.div>

            {/* Center pot icon */}
            <div className="center-icon">
              <motion.div
                animate={{
                  scale: [1, 1.08, 1],
                }}
                transition={{
                  duration: 1.5,
                  repeat: Infinity,
                  ease: 'easeInOut',
                }}
              >
                <Soup size={48} color="#FF6B35" />
              </motion.div>
              <div className="dot-indicators">
                {[0, 1, 2].map((index) => (
                  <div
                    key={index}
                    className={`dot ${index === currentPhaseIndex % 3 ? 'active' : ''}`}
                  />
                ))}
              </div>
            </div>
          </div>

          {/* Title */}
          <motion.h1
            className="processing-title"
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.2 }}
            dir={isRTL ? 'rtl' : 'ltr'}
          >
            {t('chefliCraftingMasterpiece').split('\n').map((line, i) => (
              <Fragment key={i}>
                {line}
                {i < 1 && <br />}
              </Fragment>
            ))}
          </motion.h1>

          {/* Current Phase */}
          <motion.div
            key={currentPhaseIndex}
            className="current-phase"
            initial={{ opacity: 0, y: 5 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -5 }}
            transition={{ duration: 0.4 }}
            dir={isRTL ? 'rtl' : 'ltr'}
          >
            {processingPhases[currentPhaseIndex]}
          </motion.div>

          {/* AI Engine */}
          <div className="ai-engine" dir={isRTL ? 'rtl' : 'ltr'}>
            {t('aiEngineGpt4')}
          </div>

          {/* Efficiency Bar */}
          <div className="efficiency-section">
            <div className="efficiency-header">
              <span>{t('efficiencyEngine')}</span>
              <span className="progress-percentage">{Math.round(progress)}%</span>
            </div>
            <div className="progress-bar-container">
              <motion.div
                className="progress-bar"
                initial={{ width: 0 }}
                animate={{ width: `${progress}%` }}
                transition={{ duration: 0.1 }}
              />
            </div>
          </div>

          {/* Quote */}
          <motion.div
            key={currentQuoteIndex}
            className="quote"
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            exit={{ opacity: 0 }}
            transition={{ duration: 0.5 }}
            dir={isRTL ? 'rtl' : 'ltr'}
          >
            {quotes[currentQuoteIndex]}
          </motion.div>
        </div>

        {/* Bottom Icons */}
        <div className="bottom-icons">
          <Utensils size={24} />
          <Flame size={24} />
          <Soup size={24} />
        </div>
      </div>
    </div>
  );
};

export default ProcessingPage;
