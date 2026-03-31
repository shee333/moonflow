import React, { Component, ErrorInfo, ReactNode } from 'react';

interface Props {
  children: ReactNode;
  fallback?: ReactNode;
  onError?: (error: Error, errorInfo: ErrorInfo) => void;
}

interface State {
  hasError: boolean;
  error: Error | null;
  errorInfo: ErrorInfo | null;
}

export class ErrorBoundary extends Component<Props, State> {
  constructor(props: Props) {
    super(props);
    this.state = {
      hasError: false,
      error: null,
      errorInfo: null,
    };
  }

  static getDerivedStateFromError(error: Error): Partial<State> {
    return {
      hasError: true,
      error,
    };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo): void {
    this.setState({
      error,
      errorInfo,
    });
    
    if (this.props.onError) {
      this.props.onError(error, errorInfo);
    }

    console.error('ErrorBoundary caught an error:', error, errorInfo);
  }

  handleReset = (): void => {
    this.setState({
      hasError: false,
      error: null,
      errorInfo: null,
    });
  };

  render(): ReactNode {
    if (this.state.hasError) {
      if (this.props.fallback) {
        return this.props.fallback;
      }

      return (
        <div style={{
          padding: '40px',
          maxWidth: '600px',
          margin: '40px auto',
          background: 'var(--bg-secondary)',
          borderRadius: '12px',
          boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
          fontFamily: 'system-ui, -apple-system, sans-serif',
        }}>
          <div style={{
            fontSize: '48px',
            textAlign: 'center',
            marginBottom: '20px',
          }}>
            😱
          </div>
          
          <h2 style={{
            margin: '0 0 16px 0',
            fontSize: '24px',
            color: '#e74c3c',
            textAlign: 'center',
          }}>
            出现了一些问题
          </h2>
          
          <p style={{
            color: 'var(--text-secondary)',
            textAlign: 'center',
            marginBottom: '20px',
          }}>
            抱歉，应用程序遇到了一个错误。请尝试刷新页面或重置应用状态。
          </p>

          {process.env.NODE_ENV === 'development' && this.state.error && (
            <details style={{
              marginTop: '20px',
              padding: '16px',
              background: 'var(--bg-tertiary)',
              borderRadius: '8px',
              border: '1px solid var(--border-color)',
            }}>
              <summary style={{
                cursor: 'pointer',
                fontWeight: '600',
                color: 'var(--text-primary)',
                marginBottom: '12px',
              }}>
                错误详情（开发模式）
              </summary>
              <div style={{ color: 'var(--text-primary)' }}>
                <p><strong>错误信息：</strong></p>
                <pre style={{
                  background: 'var(--bg-primary)',
                  padding: '12px',
                  borderRadius: '4px',
                  overflow: 'auto',
                  fontSize: '12px',
                  marginBottom: '12px',
                }}>
                  {this.state.error.toString()}
                </pre>
                
                <p><strong>堆栈跟踪：</strong></p>
                <pre style={{
                  background: 'var(--bg-primary)',
                  padding: '12px',
                  borderRadius: '4px',
                  overflow: 'auto',
                  fontSize: '12px',
                }}>
                  {this.state.errorInfo?.componentStack || 'No stack trace available'}
                </pre>
              </div>
            </details>
          )}

          <div style={{
            display: 'flex',
            gap: '12px',
            justifyContent: 'center',
            marginTop: '24px',
          }}>
            <button
              onClick={this.handleReset}
              style={{
                padding: '12px 24px',
                background: '#007acc',
                color: 'white',
                border: 'none',
                borderRadius: '6px',
                fontSize: '14px',
                fontWeight: '600',
                cursor: 'pointer',
                transition: 'all 0.2s',
              }}
              onMouseOver={(e) => {
                e.currentTarget.style.background = '#005a99';
                e.currentTarget.style.transform = 'translateY(-1px)';
              }}
              onMouseOut={(e) => {
                e.currentTarget.style.background = '#007acc';
                e.currentTarget.style.transform = 'translateY(0)';
              }}
            >
              重试
            </button>
            <button
              onClick={() => window.location.reload()}
              style={{
                padding: '12px 24px',
                background: 'transparent',
                color: 'var(--text-primary)',
                border: '1px solid var(--border-color)',
                borderRadius: '6px',
                fontSize: '14px',
                fontWeight: '600',
                cursor: 'pointer',
                transition: 'all 0.2s',
              }}
              onMouseOver={(e) => {
                e.currentTarget.style.background = 'var(--bg-hover)';
              }}
              onMouseOut={(e) => {
                e.currentTarget.style.background = 'transparent';
              }}
            >
              刷新页面
            </button>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}

export function withErrorBoundary<P extends object>(
  WrappedComponent: React.ComponentType<P>,
  fallback?: ReactNode,
  onError?: (error: Error, errorInfo: ErrorInfo) => void
): React.FC<P> {
  const WithErrorBoundary: React.FC<P> = (props) => (
    <ErrorBoundary fallback={fallback} onError={onError}>
      <WrappedComponent {...props} />
    </ErrorBoundary>
  );

  WithErrorBoundary.displayName = `WithErrorBoundary(${WrappedComponent.displayName || WrappedComponent.name || 'Component'})`;

  return WithErrorBoundary;
}
