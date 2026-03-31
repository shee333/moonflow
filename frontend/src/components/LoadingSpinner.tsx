import React from 'react';

interface LoadingSpinnerProps {
  size?: 'small' | 'medium' | 'large';
  color?: string;
  message?: string;
}

export function LoadingSpinner({ 
  size = 'medium', 
  color = '#007acc',
  message 
}: LoadingSpinnerProps) {
  const sizeMap = {
    small: 20,
    medium: 40,
    large: 60,
  };

  const pixelSize = sizeMap[size];

  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      gap: '12px',
    }}>
      <div style={{
        width: `${pixelSize}px`,
        height: `${pixelSize}px`,
        border: `3px solid ${color}20`,
        borderTop: `3px solid ${color}`,
        borderRadius: '50%',
        animation: 'spin 0.8s linear infinite',
      }} />
      {message && (
        <p style={{
          margin: 0,
          color: 'var(--text-secondary)',
          fontSize: '14px',
        }}>
          {message}
        </p>
      )}
      <style>{`
        @keyframes spin {
          0% { transform: rotate(0deg); }
          100% { transform: rotate(360deg); }
        }
      `}</style>
    </div>
  );
}

export function LoadingOverlay({ message }: { message?: string }) {
  return (
    <div style={{
      position: 'fixed',
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      background: 'rgba(0, 0, 0, 0.5)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      zIndex: 9999,
    }}>
      <LoadingSpinner size="large" message={message} />
    </div>
  );
}
