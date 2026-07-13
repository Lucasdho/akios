
import DataModelingCanvas from './components/Canvas/DataModelingCanvas';
import { initAgentInterface } from './utils/agentInterface';
import { useEffect } from 'react';

function App() {
  useEffect(() => {
    initAgentInterface();
  }, []);
  return (
    <DataModelingCanvas />
  );
}

export default App;
