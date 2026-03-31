import { WorkflowIDE } from './components/WorkflowIDE';
import { ThemeProvider } from './context';
import { WorkflowProvider } from './context/WorkflowContext';
import './App.css';

function App() {
  return (
    <ThemeProvider>
      <WorkflowProvider>
        <WorkflowIDE />
      </WorkflowProvider>
    </ThemeProvider>
  );
}

export default App;
