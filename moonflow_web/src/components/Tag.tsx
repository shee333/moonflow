import React from 'react';

interface TagProps {
  children: React.ReactNode;
  color?: string;
  closable?: boolean;
  onClose?: () => void;
}

export function Tag({ children, color = '#3498db', closable = false, onClose }: TagProps) {
  return (
    <span
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: '6px',
        padding: '4px 12px',
        background: `${color}20`,
        color: color,
        borderRadius: '12px',
        fontSize: '13px',
        fontWeight: '500',
        border: `1px solid ${color}40`,
      }}
    >
      {children}
      {closable && (
        <button
          onClick={onClose}
          style={{
            background: 'transparent',
            border: 'none',
            color: 'inherit',
            cursor: 'pointer',
            padding: '0',
            fontSize: '16px',
            lineHeight: '1',
            opacity: 0.7,
          }}
        >
          ×
        </button>
      )}
    </span>
  );
}
