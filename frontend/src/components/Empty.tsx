import React from 'react';

interface EmptyProps {
  description?: string;
  image?: string;
}

export function Empty({ description = 'No data', image }: EmptyProps) {
  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '48px 24px',
      textAlign: 'center',
    }}>
      <div style={{
        fontSize: '64px',
        marginBottom: '16px',
        opacity: 0.5,
      }}>
        {image || '📭'}
      </div>
      <p style={{
        margin: 0,
        color: 'var(--text-tertiary)',
        fontSize: '14px',
      }}>
        {description}
      </p>
    </div>
  );
}
