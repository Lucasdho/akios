import { Download, Upload, PlusSquare, Trash2, Hand, MousePointer2, Undo2, Redo2 } from 'lucide-react';
import { useModelingStore } from '../../store/useModelingStore';
import { useStore } from 'zustand';
import { useRef } from 'react';
import './MainToolbar.css';

export const MainToolbar = () => {
  const { 
    addEntity, 
    clearCanvas, 
    exportSpec, 
    importSpec,
    interactionMode,
    setInteractionMode
  } = useModelingStore();
  
  const { undo, redo, pastStates, futureStates } = useStore(useModelingStore.temporal);
  
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleExport = () => {
    const specJson = exportSpec();
    const blob = new Blob([specJson], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'data-model-spec.json';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  };

  const handleImport = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onload = (e) => {
        const content = e.target?.result;
        if (typeof content === 'string') {
          importSpec(content);
        }
      };
      reader.readAsText(file);
    }
    if (fileInputRef.current) {
      fileInputRef.current.value = '';
    }
  };

  return (
    <div className="main-toolbar glass-panel">
      <div className="toolbar-section">
        <span className="toolbar-title">Data Modeler</span>
      </div>
      
      <div className="toolbar-divider" />

      <div className="toolbar-actions">
        <button 
          className={`btn-icon ${interactionMode === 'pan' ? 'active' : ''}`}
          title="Mover Canvas (Pan)"
          onClick={() => setInteractionMode('pan')}
          style={{ background: interactionMode === 'pan' ? 'var(--accent-secondary)' : 'transparent', color: interactionMode === 'pan' ? '#fff' : 'inherit' }}
        >
          <Hand size={18} />
        </button>
        <button 
          className={`btn-icon ${interactionMode === 'select' ? 'active' : ''}`}
          title="Selecionar Região"
          onClick={() => setInteractionMode('select')}
          style={{ background: interactionMode === 'select' ? 'var(--accent-secondary)' : 'transparent', color: interactionMode === 'select' ? '#fff' : 'inherit' }}
        >
          <MousePointer2 size={18} />
        </button>
      </div>

      <div className="toolbar-divider" />

      <div className="toolbar-actions">
        <button 
          className="btn-icon"
          title="Desfazer (Cmd/Ctrl + Z)"
          onClick={() => undo()}
          disabled={pastStates.length === 0}
          style={{ opacity: pastStates.length === 0 ? 0.4 : 1, cursor: pastStates.length === 0 ? 'not-allowed' : 'pointer' }}
        >
          <Undo2 size={18} />
        </button>
        <button 
          className="btn-icon"
          title="Refazer (Cmd/Ctrl + Y)"
          onClick={() => redo()}
          disabled={futureStates.length === 0}
          style={{ opacity: futureStates.length === 0 ? 0.4 : 1, cursor: futureStates.length === 0 ? 'not-allowed' : 'pointer' }}
        >
          <Redo2 size={18} />
        </button>
      </div>

      <div className="toolbar-divider" />

      <div className="toolbar-actions">
        <button 
          className="btn-primary"
          onClick={() => addEntity({ x: window.innerWidth / 2 - 140, y: window.innerHeight / 2 - 100 })}
        >
          <PlusSquare size={18} /> Nova Entidade
        </button>

        <button 
          className="btn-icon"
          title="Limpar Canvas"
          onClick={() => {
            if (window.confirm('Tem certeza que deseja limpar tudo?')) {
              clearCanvas();
            }
          }}
        >
          <Trash2 size={18} />
        </button>
      </div>

      <div className="toolbar-divider" />

      <div className="toolbar-actions">
        <input 
          type="file" 
          ref={fileInputRef} 
          style={{ display: 'none' }} 
          accept=".json"
          onChange={handleImport}
        />
        <button 
          className="btn-icon"
          title="Importar JSON Spec"
          onClick={() => fileInputRef.current?.click()}
          style={{ gap: '8px', padding: '8px 16px', fontSize: '14px', fontWeight: 500 }}
        >
          <Upload size={18} /> Importar
        </button>

        <button 
          className="btn-icon export-btn"
          title="Exportar JSON Spec"
          onClick={handleExport}
        >
          <Download size={18} /> Exportar
        </button>
      </div>
    </div>
  );
};

export default MainToolbar;
