import '@testing-library/dom';
import { expect, afterEach, vi } from 'vitest';
import { cleanup } from '@testing-library/react';

afterEach(() => {
  cleanup();
});

global.fetch = vi.fn();

Object.defineProperty(window, 'matchMedia', {
  writable: true,
  value: vi.fn().mockImplementation((query: string) => ({
    matches: false,
    media: query,
    onchange: null,
    addListener: vi.fn(),
    removeListener: vi.fn(),
    addEventListener: vi.fn(),
    removeEventListener: vi.fn(),
    dispatchEvent: vi.fn(),
  })),
});

window.URL.createObjectURL = vi.fn(() => 'blob:mock-url');
window.URL.revokeObjectURL = vi.fn();
