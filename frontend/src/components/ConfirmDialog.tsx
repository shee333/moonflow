import React from 'react';

interface ConfirmDialogProps {
  isOpen: boolean;
  title: string;
  message: string;
  confirmText?: string;
  cancelText?: string;
  onConfirm: () => void;
  onCancel: () => void;
  type?: 'danger' | 'warning' | 'info';
}

export function ConfirmDialog({
  isOpen,
  title,
  message,
  confirmText = '确认',
  cancelText = '取消',
  onConfirm,
  onCancel,
  type = 'danger',
}: ConfirmDialogProps) {
  if (!isOpen) return null;

  const colors = {
    danger: '#e74c3c',
    warning: '#f39c12',
    info: '#3498db',
  };

  const color = colors[type];

  return (
    <div
      style={{
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        background: 'rgba(0, 0, 0, 0.6)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 9999,
        animation: 'fadeIn 0.2s',
      }}
      onClick={onCancel}
    >
      <div
        style={{
          background: 'var(--bg-secondary)',
          borderRadius: '12px',
          padding: '24px',
          maxWidth: '400px',
          width: '90%',
          boxShadow: '0 20px 60px rgba(0, 0, 0, 0.4)',
          animation: 'slideUp 0.3s',
        }}
        onClick={(e) => e.stopPropagation()}
      >
        <h3 style={{
          margin: '0 0 12px 0',
          fontSize: '18px',
          fontWeight: '600',
          color: color,
        }}>
          {title}
        </h3>
        
        <p style={{
          margin: '0 0 20px 0',
          color: 'var(--text-secondary)',
          fontSize: '14px',
          lineHeight: 1.5,
        }}>
          {message}
        </p>

        <div style={{
          display: 'flex',
          gap: '12px',
          justifyContent: 'flex-end',
        }}>
          <button
            onClick={onCancel}
            style={{
              padding: '8px 16px',
              background: 'transparent',
              border: '1px solid var(--border-color)',
              borderRadius: '6px',
              color: 'var(--text-secondary)',
              fontSize: '14px',
              fontWeight: '600',
              cursor: 'pointer',
              transition: 'all 0.2s',
            }}
          >
            {cancelText}
          </button>
          <button
            onClick={onConfirm}
            style={{
              padding: '8px 16px',
              background: color,
              border: 'none',
              borderRadius: '6px',
              color: 'white',
              fontSize: '14px',
              fontWeight: '600',
              cursor: 'pointer',
              transition: 'all 0.2s',
            }}
          >
            {confirmText}
          </button>
        </div>
      </div>

      <style>{`
        @keyframes fadeIn {
          from { opacity: 0; }
          to { opacity: 1; }
        }
        @keyframes slideUp {
          from { 
            opacity: 0;
            transform: translateY(20px);
          }
          to { 
            opacity: 1;
            transform: translateY(0);
          }
        }
      `}</style>
    </div>
  );
}

export function useConfirmDialog() {
  const [dialog, setDialog] = React.useState<{
    isOpen: boolean;
    title: string;
    message: string;
    onConfirm: () => void;
    type?: 'danger' | 'warning' | 'info';
  }>({
    isOpen: false,
    title: '',
    message: '',
    onConfirm: () => {},
  });

  const confirm = (
    title: string,
    message: string,
    onConfirm: () => void,
    type: 'danger' | 'warning' | 'info' = 'danger'
  ) => {
    setDialog({ isOpen: true, title, message, onConfirm, type });
  };

  const handleConfirm = () => {
    dialog.onConfirm();
    setDialog((prev) => ({ ...prev, isOpen: false }));
  };

  const handleCancel = () => {
    setDialog((prev) => ({ ...prev, isOpen: false }));
  };

  return {
    ConfirmDialogComponent: () => (
      <ConfirmDialog
        isOpen={dialog.isOpen}
        title={dialog.title}
        message={dialog.message}
        onConfirm={handleConfirm}
        onCancel={handleCancel}
        type={dialog.type}
      />
    ),
    confirm,
  };
}
