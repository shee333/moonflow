import { describe, it, expect, beforeEach } from 'vitest';
import { renderHook, act } from '@testing-library/react';
import { useHistory } from '../hooks/useHistory';

describe('useHistory', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  describe('initial state', () => {
    it('should initialize with the provided present value', () => {
      const { result } = renderHook(() => useHistory('initial'));
      expect(result.current.present).toBe('initial');
      expect(result.current.past).toEqual([]);
      expect(result.current.future).toEqual([]);
    });

    it('should initialize with empty past and future', () => {
      const { result } = renderHook(() => useHistory({ count: 0 }));
      expect(result.current.past).toEqual([]);
      expect(result.current.future).toEqual([]);
    });
  });

  describe('set', () => {
    it('should update present and add current to past', () => {
      const { result } = renderHook(() => useHistory('initial'));

      act(() => {
        result.current.set('updated');
      });

      expect(result.current.present).toBe('updated');
      expect(result.current.past).toEqual(['initial']);
      expect(result.current.future).toEqual([]);
    });

    it('should clear future when new change is made after undo', () => {
      const { result } = renderHook(() => useHistory('initial'));

      act(() => {
        result.current.set('v1');
      });

      act(() => {
        result.current.set('v2');
      });

      act(() => {
        result.current.undo();
      });

      expect(result.current.present).toBe('v1');

      act(() => {
        result.current.set('v1-alternate');
      });

      expect(result.current.present).toBe('v1-alternate');
      expect(result.current.future).toEqual([]);
    });
  });

  describe('undo', () => {
    it('should revert to previous state', () => {
      const { result } = renderHook(() => useHistory('initial'));

      act(() => {
        result.current.set('v1');
      });

      act(() => {
        result.current.set('v2');
      });

      act(() => {
        result.current.undo();
      });

      expect(result.current.present).toBe('v1');
      expect(result.current.past).toEqual(['initial']);
      expect(result.current.future).toEqual(['v2']);
    });

    it('should not change state when past is empty', () => {
      const { result } = renderHook(() => useHistory('initial'));

      act(() => {
        result.current.undo();
      });

      expect(result.current.present).toBe('initial');
      expect(result.current.past).toEqual([]);
    });
  });

  describe('redo', () => {
    it('should restore future state', () => {
      const { result } = renderHook(() => useHistory('initial'));

      act(() => {
        result.current.set('v1');
      });

      act(() => {
        result.current.undo();
      });

      expect(result.current.present).toBe('initial');

      act(() => {
        result.current.redo();
      });

      expect(result.current.present).toBe('v1');
      expect(result.current.past).toEqual(['initial']);
      expect(result.current.future).toEqual([]);
    });

    it('should not change state when future is empty', () => {
      const { result } = renderHook(() => useHistory('initial'));

      act(() => {
        result.current.redo();
      });

      expect(result.current.present).toBe('initial');
    });
  });

  describe('clear', () => {
    it('should clear past history', () => {
      const { result } = renderHook(() => useHistory('initial'));

      act(() => {
        result.current.set('v1');
      });

      act(() => {
        result.current.set('v2');
      });

      act(() => {
        result.current.clear();
      });

      expect(result.current.present).toBe('initial');
      expect(result.current.past).toEqual([]);
      expect(result.current.future).toEqual([]);
    });
  });
});
