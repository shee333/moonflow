export interface PerformanceMetric {
  name: string;
  value: number;
  unit: string;
  timestamp: number;
}

export interface PerformanceReport {
  metrics: PerformanceMetric[];
  summary: {
    totalMetrics: number;
    avgRenderTime: number;
    avgMemoryUsage: number;
  };
}

class PerformanceMonitor {
  private metrics: PerformanceMetric[] = [];
  private renderStartTimes: Map<string, number> = new Map();
  private static instance: PerformanceMonitor;

  private constructor() {
    if (typeof window !== 'undefined') {
      this.setupPerformanceObserver();
    }
  }

  public static getInstance(): PerformanceMonitor {
    if (!PerformanceMonitor.instance) {
      PerformanceMonitor.instance = new PerformanceMonitor();
    }
    return PerformanceMonitor.instance;
  }

  private setupPerformanceObserver(): void {
    if ('PerformanceObserver' in window) {
      try {
        const observer = new PerformanceObserver((list) => {
          for (const entry of list.getEntries()) {
            if (entry.entryType === 'measure') {
              this.addMetric('performance', entry.name, entry.duration, 'ms');
            }
          }
        });
        observer.observe({ entryTypes: ['measure', 'navigation', 'resource'] });
      } catch (e) {
        console.warn('PerformanceObserver not supported:', e);
      }
    }
  }

  startMeasure(name: string): void {
    if (typeof window !== 'undefined' && 'performance' in window) {
      performance.mark(`${name}-start`);
      this.renderStartTimes.set(name, Date.now());
    }
  }

  endMeasure(name: string): number | null {
    if (typeof window !== 'undefined' && 'performance' in window) {
      const startTime = this.renderStartTimes.get(name);
      if (startTime !== undefined) {
        const duration = Date.now() - startTime;
        this.addMetric('operation', name, duration, 'ms');
        this.renderStartTimes.delete(name);
        
        performance.mark(`${name}-end`);
        try {
          performance.measure(name, `${name}-start`, `${name}-end`);
        } catch (e) {
          console.warn('Failed to create performance measure:', e);
        }
        
        return duration;
      }
    }
    return null;
  }

  addMetric(category: string, name: string, value: number, unit: string): void {
    this.metrics.push({
      name: `${category}:${name}`,
      value,
      unit,
      timestamp: Date.now(),
    });

    if (this.metrics.length > 1000) {
      this.metrics = this.metrics.slice(-500);
    }
  }

  getMetrics(): PerformanceMetric[] {
    return [...this.metrics];
  }

  getMetricsByCategory(category: string): PerformanceMetric[] {
    return this.metrics.filter((m) => m.name.startsWith(`${category}:`));
  }

  getAverageMetric(name: string): number | null {
    const filtered = this.metrics.filter((m) => m.name === name);
    if (filtered.length === 0) return null;
    
    const sum = filtered.reduce((acc, m) => acc + m.value, 0);
    return sum / filtered.length;
  }

  getReport(): PerformanceReport {
    const renderMetrics = this.getMetricsByCategory('render');
    const memoryMetrics = this.getMetricsByCategory('memory');

    return {
      metrics: this.metrics,
      summary: {
        totalMetrics: this.metrics.length,
        avgRenderTime: renderMetrics.length > 0
          ? renderMetrics.reduce((acc, m) => acc + m.value, 0) / renderMetrics.length
          : 0,
        avgMemoryUsage: memoryMetrics.length > 0
          ? memoryMetrics.reduce((acc, m) => acc + m.value, 0) / memoryMetrics.length
          : 0,
      },
    };
  }

  clearMetrics(): void {
    this.metrics = [];
    this.renderStartTimes.clear();
  }

  getMemoryUsage(): { used: number; total: number; percentage: number } | null {
    if (typeof window !== 'undefined' && 'memory' in performance) {
      const memory = (performance as any).memory;
      return {
        used: Math.round(memory.usedJSHeapSize / 1048576),
        total: Math.round(memory.totalJSHeapSize / 1048576),
        percentage: Math.round((memory.usedJSHeapSize / memory.totalJSHeapSize) * 100),
      };
    }
    return null;
  }

  getNavigationTiming(): PerformanceNavigationTiming | null {
    if (typeof window !== 'undefined' && 'performance' in window) {
      const entries = performance.getEntriesByType('navigation');
      if (entries.length > 0) {
        return entries[0] as PerformanceNavigationTiming;
      }
    }
    return null;
  }

  logPerformanceSummary(): void {
    const memory = this.getMemoryUsage();
    const timing = this.getNavigationTiming();
    const report = this.getReport();

    console.group('📊 Performance Summary');
    console.log('Total Metrics:', report.summary.totalMetrics);
    console.log('Avg Render Time:', report.summary.avgRenderTime.toFixed(2), 'ms');
    
    if (memory) {
      console.log('Memory Usage:', `${memory.used}MB / ${memory.total}MB (${memory.percentage}%)`);
    }
    
    if (timing) {
      console.log('Page Load Time:', timing.loadEventEnd - timing.fetchStart, 'ms');
      console.log('DOM Content Loaded:', timing.domContentLoadedEventEnd - timing.fetchStart, 'ms');
    }
    console.groupEnd();
  }
}

export const performanceMonitor = PerformanceMonitor.getInstance();

export function measureAsync<T>(
  name: string,
  fn: () => Promise<T>
): Promise<T> {
  return new Promise(async (resolve, reject) => {
    performanceMonitor.startMeasure(name);
    try {
      const result = await fn();
      performanceMonitor.endMeasure(name);
      resolve(result);
    } catch (error) {
      performanceMonitor.endMeasure(name);
      reject(error);
    }
  });
}

export function measureSync<T>(
  name: string,
  fn: () => T
): T {
  performanceMonitor.startMeasure(name);
  try {
    const result = fn();
    performanceMonitor.endMeasure(name);
    return result;
  } catch (error) {
    performanceMonitor.endMeasure(name);
    throw error;
  }
}
