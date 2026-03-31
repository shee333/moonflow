import React from 'react';

interface AvatarProps {
  src?: string;
  name?: string;
  size?: 'small' | 'medium' | 'large';
}

export function Avatar({ src, name, size = 'medium' }: AvatarProps) {
  const sizes = {
    small: 32,
    medium: 40,
    large: 56,
  };

  const pixelSize = sizes[size];

  const getInitials = (name: string) => {
    return name
      .split(' ')
      .map((n) => n[0])
      .join('')
      .toUpperCase()
      .slice(0, 2);
  };

  const getRandomColor = (name: string) => {
    const colors = [
      '#3498db', '#9b59b6', '#e74c3c', '#f39c12',
      '#27ae60', '#2980b9', '#8e44ad', '#16a085',
    ];
    const index = name.split('').reduce((acc, char) => acc + char.charCodeAt(0), 0);
    return colors[index % colors.length];
  };

  if (src) {
    return (
      <img
        src={src}
        alt={name || 'Avatar'}
        style={{
          width: `${pixelSize}px`,
          height: `${pixelSize}px`,
          borderRadius: '50%',
          objectFit: 'cover',
        }}
      />
    );
  }

  return (
    <div
      style={{
        width: `${pixelSize}px`,
        height: `${pixelSize}px`,
        borderRadius: '50%',
        backgroundColor: name ? getRandomColor(name) : 'var(--bg-tertiary)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        color: 'white',
        fontSize: `${pixelSize / 2.5}px`,
        fontWeight: 'bold',
      }}
    >
      {name ? getInitials(name) : '?'}
    </div>
  );
}
