import { useState, useCallback } from 'react';

export function useCopyToClipboard(resetInterval: number = 2000) {
  const [copiedValue, setCopiedValue] = useState<string | null>(null);
  const [copyError, setCopyError] = useState<Error | null>(null);

  const copy = useCallback(async (text: string) => {
    try {
      await navigator.clipboard.writeText(text);
      setCopiedValue(text);
      setCopyError(null);

      if (resetInterval > 0) {
        setTimeout(() => {
          setCopiedValue(null);
        }, resetInterval);
      }

      return true;
    } catch (error) {
      setCopyError(error as Error);
      setCopiedValue(null);
      return false;
    }
  }, [resetInterval]);

  return { copiedValue, copy, copyError };
}
