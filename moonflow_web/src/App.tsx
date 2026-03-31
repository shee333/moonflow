import { WorkflowIDE } from './components/WorkflowIDE';
import { ThemeProvider } from './context';
import './App.css';

function App() {
  return (
    <ThemeProvider>
      <WorkflowIDE />
    </ThemeProvider>
  );
}

export default App;
