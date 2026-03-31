import React from 'react';

interface BadgeProps {
  count?: number;
  dot?: boolean;
  color?: string;
  size?: 'small' | 'default';
  overflowCount?: number;
}

export function Badge({ 
  count, 
  dot = false, 
  color = '#e74c3c',
  size = 'default',
  overflowCount = 99 
}: BadgeProps) {
  if (dot && !count) {
    return (
      <span style={{
        display: 'inline-block',
        width: '8px',
        height: '8px',
        borderRadius: '50%',
        background: color,
        position: 'absolute',
        top: '-2px',
        right: '-2px',
      }} />
    );
  }

  if (!count) return null;

  const displayCount = count > overflowCount ? `${overflowCount}+` : count;
  const isSmall = size === 'small';

  return (
    <span
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        justifyContent: 'center',
        minWidth: isSmall ? '16px' : '20px',
        height: isSmall ? '16px' : '20px',
        padding: isSmall ? '0 4px' : '0 6px',
        background: color,
        color: 'white',
        fontSize: isSmall ? '10px' : '12px',
        fontWeight: 'bold',
        borderRadius: '10px',
        lineHeight: 1,
        boxSizing: 'border-box',
      }}
    >
      {displayCount}
    </span>
  );
}
