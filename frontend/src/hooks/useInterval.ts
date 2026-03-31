import { useState, useEffect } from 'react';

export function useInterval(callback: () => void, delay: number | null) {
  useEffect(() => {
    if (delay === null) {
      return;
    }

    const id = setInterval(callback, delay);
    return () => clearInterval(id);
  }, [callback, delay]);
}

export function useTimeout(callback: () => void, delay: number | null) {
  useEffect(() => {
    if (delay === null) {
      return;
    }

    const id = setTimeout(callback, delay);
    return () => clearTimeout(id);
  }, [callback, delay]);
}

export function usePrevious<T>(value: T): T | undefined {
  const [current, setCurrent] = useState<T>(value);
  const [previous, setPrevious] = useState<T | undefined>(undefined);

  if (value !== current) {
    setPrevious(current);
    setCurrent(value);
  }

  return previous;
}

export function useDidMount(callback: () => void): void {
  useEffect(() => {
    callback();
  }, []);
}

export function useWillUnmount(callback: () => void): void {
  useEffect(() => {
    return () => {
      callback();
    };
  }, []);
}
