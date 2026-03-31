import { useState, useCallback, useRef } from 'react';

interface HistoryState<T> {
  past: T[];
  present: T;
  future: T[];
}

interface HistoryActions<T> {
  set: (newPresent: T) => void;
  undo: () => void;
  redo: () => void;
  canUndo: boolean;
  canRedo: boolean;
  clear: () => void;
}

type History<T> = HistoryState<T> & HistoryActions<T>;

export function useHistory<T>(initialPresent: T, maxHistory: number = 50): History<T> {
  const initialRef = useRef(initialPresent);
  
  const [state, setState] = useState<HistoryState<T>>({
    past: [],
    present: initialPresent,
    future: [],
  });

  const canUndo = state.past.length > 0;
  const canRedo = state.future.length > 0;

  const set = useCallback(
    (newPresent: T) => {
      setState((currentState) => {
        const newPast = [...currentState.past, currentState.present];
        
        if (newPast.length > maxHistory) {
          newPast.shift();
        }

        return {
          past: newPast,
          present: newPresent,
          future: [],
        };
      });
    },
    [maxHistory]
  );

  const undo = useCallback(() => {
    setState((currentState) => {
      if (currentState.past.length === 0) return currentState;

      const previous = currentState.past[currentState.past.length - 1];
      const newPast = currentState.past.slice(0, currentState.past.length - 1);

      return {
        past: newPast,
        present: previous,
        future: [currentState.present, ...currentState.future],
      };
    });
  }, []);

  const redo = useCallback(() => {
    setState((currentState) => {
      if (currentState.future.length === 0) return currentState;

      const next = currentState.future[0];
      const newFuture = currentState.future.slice(1);

      return {
        past: [...currentState.past, currentState.present],
        present: next,
        future: newFuture,
      };
    });
  }, []);

  const clear = useCallback(() => {
    setState({
      past: [],
      present: initialRef.current,
      future: [],
    });
  }, []);

  return {
    ...state,
    set,
    undo,
    redo,
    canUndo,
    canRedo,
    clear,
  };
}
