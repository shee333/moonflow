import Editor from '@monaco-editor/react';
import { useCallback } from 'react';

interface CodeEditorProps {
  value: string;
  onChange?: (value: string) => void;
  language?: string;
  readOnly?: boolean;
  height?: string;
}

export function CodeEditor({
  value,
  onChange,
  language = 'json',
  readOnly = false,
  height = '400px',
}: CodeEditorProps) {
  const handleEditorChange = useCallback(
    (newValue: string | undefined) => {
      if (onChange && newValue !== undefined) {
        onChange(newValue);
      }
    },
    [onChange],
  );

  return (
    <div style={{ height, width: '100%' }}>
      <Editor
        height={height}
        language={language}
        value={value}
        onChange={handleEditorChange}
        options={{
          readOnly,
          minimap: { enabled: true },
          fontSize: 14,
          lineNumbers: 'on',
          roundedSelection: true,
          scrollBeyondLastLine: false,
          automaticLayout: true,
          tabSize: 2,
          wordWrap: 'on',
          padding: { top: 10 },
        }}
        theme="vs-dark"
      />
    </div>
  );
}
