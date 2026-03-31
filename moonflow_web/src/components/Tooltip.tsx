import React, { ReactNode, useState } from 'react';

interface TooltipProps {
  content: string;
  children: ReactNode;
  position?: 'top' | 'bottom' | 'left' | 'right';
}

export function Tooltip({ content, children, position = 'top' }: TooltipProps) {
  const [show, setShow] = useState(false);

  const positions = {
    top: { top: '-8px', left: '50%', transform: 'translateX(-50%)' },
    bottom: { bottom: '-8px', left: '50%', transform: 'translateX(-50%)' },
    left: { left: '-8px', top: '50%', transform: 'translateY(-50%)' },
    right: { right: '-8px', top: '50%', transform: 'translateY(-50%)' },
  };

  const arrowPositions = {
    top: { bottom: '-4px', left: '50%', transform: 'translateX(-50%) rotate(45deg)' },
    bottom: { top: '-4px', left: '50%', transform: 'translateX(-50%) rotate(45deg)' },
    left: { right: '-4px', top: '50%', transform: 'translateY(-50%) rotate(45deg)' },
    right: { left: '-4px', top: '50%', transform: 'translateY(-50%) rotate(45deg)' },
  };

  return (
    <div
      style={{ position: 'relative', display: 'inline-block' }}
      onMouseEnter={() => setShow(true)}
      onMouseLeave={() => setShow(false)}
    >
      {children}
      {show && (
        <div style={{
          position: 'absolute',
          ...positions[position],
          zIndex: 9999,
          padding: '6px 12px',
          background: 'var(--text-primary)',
          color: 'var(--bg-primary)',
          borderRadius: '4px',
          fontSize: '13px',
          whiteSpace: 'nowrap',
          boxShadow: '0 4px 12px rgba(0, 0, 0, 0.2)',
          pointerEvents: 'none',
        }}>
          {content}
          <div style={{
            position: 'absolute',
            width: '8px',
            height: '8px',
            background: 'var(--text-primary)',
            ...arrowPositions[position],
          }} />
        </div>
      )}
    </div>
  );
}
