export interface UsageStats {
  workflowsCreated: number;
  workflowsSaved: number;
  workflowsLoaded: number;
  nodesAdded: Record<string, number>;
  codeGenerations: number;
  edgesCreated: number;
  nodesDeleted: number;
  edgesDeleted: number;
  lastSession: string;
  totalSessions: number;
  sessionStartTime: string;
}

const STORAGE_KEY = 'moonflow_usage_stats';

const defaultStats: UsageStats = {
  workflowsCreated: 0,
  workflowsSaved: 0,
  workflowsLoaded: 0,
  nodesAdded: {},
  codeGenerations: 0,
  edgesCreated: 0,
  nodesDeleted: 0,
  edgesDeleted: 0,
  lastSession: new Date().toISOString(),
  totalSessions: 0,
  sessionStartTime: new Date().toISOString(),
};

export class AnalyticsService {
  private stats: UsageStats;

  constructor() {
    this.stats = this.loadStats();
    this.stats.totalSessions++;
    this.stats.sessionStartTime = new Date().toISOString();
    this.saveStats();
  }

  private loadStats(): UsageStats {
    try {
      const stored = localStorage.getItem(STORAGE_KEY);
      if (stored) {
        return JSON.parse(stored);
      }
    } catch (e) {
      console.error('Failed to load usage stats:', e);
    }
    return { ...defaultStats };
  }

  private saveStats(): void {
    try {
      this.stats.lastSession = new Date().toISOString();
      localStorage.setItem(STORAGE_KEY, JSON.stringify(this.stats));
    } catch (e) {
      console.error('Failed to save usage stats:', e);
    }
  }

  trackWorkflowCreated(): void {
    this.stats.workflowsCreated++;
    this.saveStats();
  }

  trackWorkflowSaved(): void {
    this.stats.workflowsSaved++;
    this.saveStats();
  }

  trackWorkflowLoaded(): void {
    this.stats.workflowsLoaded++;
    this.saveStats();
  }

  trackNodeAdded(nodeType: string): void {
    this.stats.nodesAdded[nodeType] = (this.stats.nodesAdded[nodeType] || 0) + 1;
    this.saveStats();
  }

  trackCodeGeneration(): void {
    this.stats.codeGenerations++;
    this.saveStats();
  }

  trackEdgeCreated(): void {
    this.stats.edgesCreated++;
    this.saveStats();
  }

  trackNodeDeleted(): void {
    this.stats.nodesDeleted++;
    this.saveStats();
  }

  trackEdgeDeleted(): void {
    this.stats.edgesDeleted++;
    this.saveStats();
  }

  getStats(): UsageStats {
    return { ...this.stats };
  }

  getTopComponents(limit: number = 5): Array<{ type: string; count: number }> {
    return Object.entries(this.stats.nodesAdded)
      .map(([type, count]) => ({ type, count }))
      .sort((a, b) => b.count - a.count)
      .slice(0, limit);
  }

  resetStats(): void {
    this.stats = {
      ...defaultStats,
      totalSessions: this.stats.totalSessions,
      sessionStartTime: new Date().toISOString(),
    };
    this.saveStats();
  }
}

let analyticsInstance: AnalyticsService | null = null;

export function getAnalytics(): AnalyticsService {
  if (!analyticsInstance) {
    analyticsInstance = new AnalyticsService();
  }
  return analyticsInstance;
}

export function createAnalyticsReport(): string {
  const stats = getAnalytics().getStats();
  const topComponents = getAnalytics().getTopComponents(5);
  
  const report = `
MoonFlow 使用统计报告
==================

会话信息:
- 当前会话开始: ${new Date(stats.sessionStartTime).toLocaleString()}
- 上次会话: ${new Date(stats.lastSession).toLocaleString()}
- 总会话数: ${stats.totalSessions}

工作流:
- 创建的工作流: ${stats.workflowsCreated}
- 保存的工作流: ${stats.workflowsSaved}
- 加载的工作流: ${stats.workflowsLoaded}

节点操作:
- 添加的节点: ${Object.values(stats.nodesAdded).reduce((a, b) => a + b, 0)}
- 删除的节点: ${stats.nodesDeleted}

边操作:
- 创建的边: ${stats.edgesCreated}
- 删除的边: ${stats.edgesDeleted}

代码生成:
- 代码生成次数: ${stats.codeGenerations}

最常用的组件:
${topComponents.map((c, i) => `${i + 1}. ${c.type}: ${c.count} 次`).join('\n')}

生成时间: ${new Date().toLocaleString()}
  `.trim();

  return report;
}
