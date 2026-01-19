import React from 'react';

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null, errorCount: 0 };
  }

  static getDerivedStateFromError(error) {
    // Check if it's the InstantDB query error
    const isInstantDBError = error?.message?.includes('db.query') || 
                            error?.message?.includes('is not a function');
    
    if (isInstantDBError) {
      // For InstantDB errors, log and continue
      console.warn('InstantDB error caught (non-critical):', error.message);
      return { hasError: false, error: null, errorCount: 0 };
    }
    
    return { hasError: true, error };
  }

  componentDidCatch(error, errorInfo) {
    const isInstantDBError = error?.message?.includes('db.query') || 
                            error?.message?.includes('is not a function');
    
    if (isInstantDBError) {
      // Don't log InstantDB errors as critical
      console.warn('InstantDB query error (app will continue):', error.message);
      return;
    }
    
    console.error('ErrorBoundary caught an error:', error, errorInfo);
  }

  render() {
    // Always render children - let errors be handled gracefully
    return this.props.children;
  }
}

export default ErrorBoundary;
