import React from 'react';

interface DividerProps {
  vertical?: boolean;
  color?: string;
  width?: string;
  height?: string;
}

export function Divider({ 
  vertical = false, 
  color = 'var(--border-color)',
  width = '1px',
  height = '100%',
}: DividerProps) {
  return (
    <div
      style={{
        width: vertical ? width : '100%',
        height: vertical ? height : height,
        backgroundColor: color,
        flexShrink: 0,
      }}
    />
  );
}
