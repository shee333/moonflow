import React, { useState } from 'react';
import './KeyboardShortcutsHelp.css';

interface Shortcut {
  keys: string[];
  description: string;
  category: string;
}

const shortcuts: Shortcut[] = [
  { keys: ['Ctrl', 'Z'], description: '撤销', category: '编辑' },
  { keys: ['Ctrl', 'Shift', 'Z'], description: '重做', category: '编辑' },
  { keys: ['Ctrl', 'Y'], description: '重做 (替代)', category: '编辑' },
  { keys: ['Ctrl', 'S'], description: '保存工作流', category: '文件' },
  { keys: ['Delete'], description: '删除选中节点/边', category: '编辑' },
  { keys: ['Backspace'], description: '删除选中节点/边', category: '编辑' },
  { keys: ['Escape'], description: '取消选择/关闭面板', category: '导航' },
  { keys: ['双击'], description: '编辑节点配置', category: '交互' },
  { keys: ['拖拽'], description: '移动节点', category: '交互' },
  { keys: ['滚轮'], description: '缩放画布', category: '导航' },
  { keys: ['Ctrl', '滚轮'], description: '缩放画布 (替代)', category: '导航' },
  { keys: ['空格 + 拖拽'], description: '平移画布', category: '导航' },
];

export function KeyboardShortcutsHelp() {
  const [isOpen, setIsOpen] = useState(false);

  const groupedShortcuts = shortcuts.reduce((acc, shortcut) => {
    if (!acc[shortcut.category]) {
      acc[shortcut.category] = [];
    }
    acc[shortcut.category].push(shortcut);
    return acc;
  }, {} as Record<string, Shortcut[]>);

  if (!isOpen) {
    return (
      <button 
        className="shortcuts-toggle"
        onClick={() => setIsOpen(true)}
        title="快捷键帮助"
      >
        <span className="icon">⌨️</span>
      </button>
    );
  }

  return (
    <div className="shortcuts-overlay" onClick={() => setIsOpen(false)}>
      <div className="shortcuts-panel" onClick={(e) => e.stopPropagation()}>
        <div className="panel-header">
          <h3>键盘快捷键</h3>
          <button className="close-btn" onClick={() => setIsOpen(false)}>×</button>
        </div>

        <div className="panel-content">
          {Object.entries(groupedShortcuts).map(([category, items]) => (
            <div key={category} className="shortcut-category">
              <h4>{category}</h4>
              <div className="shortcut-list">
                {items.map((shortcut, index) => (
                  <div key={index} className="shortcut-item">
                    <div className="shortcut-keys">
                      {shortcut.keys.map((key, keyIndex) => (
                        <React.Fragment key={keyIndex}>
                          <kbd>{key}</kbd>
                          {keyIndex < shortcut.keys.length - 1 && (
                            <span className="plus">+</span>
                          )}
                        </React.Fragment>
                      ))}
                    </div>
                    <span className="shortcut-description">{shortcut.description}</span>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>

        <div className="panel-footer">
          <p>提示: 在输入框中时，快捷键不会触发</p>
        </div>
      </div>
    </div>
  );
}
