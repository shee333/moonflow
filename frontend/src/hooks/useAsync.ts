import { useState, useCallback } from 'react';

export function useAsync<T>(
  asyncFunction: () => Promise<T>
): {
  execute: () => Promise<T | undefined>;
  status: 'idle' | 'pending' | 'success' | 'error';
  value: T | null;
  error: Error | null;
} {
  const [status, setStatus] = useState<'idle' | 'pending' | 'success' | 'error'>('idle');
  const [value, setValue] = useState<T | null>(null);
  const [error, setError] = useState<Error | null>(null);

  const execute = useCallback(async () => {
    setStatus('pending');
    setValue(null);
    setError(null);

    try {
      const response = await asyncFunction();
      setValue(response);
      setStatus('success');
      return response;
    } catch (error) {
      setError(error as Error);
      setStatus('error');
      return undefined;
    }
  }, [asyncFunction]);

  return { execute, status, value, error };
}
