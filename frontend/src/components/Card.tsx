import React, { ReactNode } from 'react';

interface CardProps {
  title?: string;
  children: ReactNode;
  footer?: ReactNode;
  onClick?: () => void;
  hoverable?: boolean;
  style?: React.CSSProperties;
}

export function Card({ 
  title, 
  children, 
  footer,
  onClick,
  hoverable = false,
  style 
}: CardProps) {
  return (
    <div
      onClick={onClick}
      style={{
        background: 'var(--bg-secondary)',
        border: '1px solid var(--border-color)',
        borderRadius: '8px',
        overflow: 'hidden',
        transition: 'all 0.2s',
        cursor: onClick ? 'pointer' : 'default',
        ...(hoverable && {
          ':hover': {
            boxShadow: '0 4px 12px rgba(0, 0, 0, 0.15)',
            transform: 'translateY(-2px)',
          },
        }),
        ...style,
      }}
    >
      {title && (
        <div style={{
          padding: '16px 20px',
          borderBottom: '1px solid var(--border-color)',
          background: 'var(--bg-tertiary)',
        }}>
          <h3 style={{
            margin: 0,
            fontSize: '16px',
            fontWeight: '600',
            color: 'var(--text-primary)',
          }}>
            {title}
          </h3>
        </div>
      )}
      
      <div style={{
        padding: '20px',
      }}>
        {children}
      </div>

      {footer && (
        <div style={{
          padding: '12px 20px',
          borderTop: '1px solid var(--border-color)',
          background: 'var(--bg-tertiary)',
        }}>
          {footer}
        </div>
      )}
    </div>
  );
}
