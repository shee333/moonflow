import React, { ReactNode } from 'react';

interface Tab {
  key: string;
  label: string;
  icon?: string;
  content: ReactNode;
  disabled?: boolean;
}

interface TabsProps {
  tabs: Tab[];
  activeKey?: string;
  onChange?: (key: string) => void;
}

export function Tabs({ tabs, activeKey, onChange }: TabsProps) {
  const [active, setActive] = React.useState(activeKey || tabs[0]?.key);

  const handleChange = (key: string) => {
    setActive(key);
    onChange?.(key);
  };

  const activeTab = tabs.find((tab) => tab.key === active);

  return (
    <div style={{ width: '100%' }}>
      <div style={{
        display: 'flex',
        borderBottom: '2px solid var(--border-color)',
        gap: '4px',
      }}>
        {tabs.map((tab) => (
          <button
            key={tab.key}
            onClick={() => !tab.disabled && handleChange(tab.key)}
            disabled={tab.disabled}
            style={{
              padding: '12px 20px',
              background: 'transparent',
              border: 'none',
              borderBottom: active === tab.key 
                ? '2px solid var(--node-trigger)' 
                : '2px solid transparent',
              color: active === tab.key 
                ? 'var(--node-trigger)' 
                : tab.disabled 
                  ? 'var(--text-tertiary)' 
                  : 'var(--text-secondary)',
              fontSize: '14px',
              fontWeight: '600',
              cursor: tab.disabled ? 'not-allowed' : 'pointer',
              transition: 'all 0.2s',
              marginBottom: '-2px',
            }}
          >
            {tab.icon && <span style={{ marginRight: '6px' }}>{tab.icon}</span>}
            {tab.label}
          </button>
        ))}
      </div>
      <div style={{ padding: '20px 0' }}>
        {activeTab?.content}
      </div>
    </div>
  );
}
