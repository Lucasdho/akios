import { memo, useState, useEffect } from 'react';
import { Handle, Position, NodeToolbar } from '@xyflow/react';
import { Plus, X, Key, AlignLeft } from 'lucide-react';
import type { EntityNodeData } from '../../store/useModelingStore';
import { useModelingStore } from '../../store/useModelingStore';
import { InlineColorPicker } from '../Toolbar/InlineColorPicker';
import './EntityNode.css';

interface EntityNodeProps {
  id: string;
  data: EntityNodeData;
  selected?: boolean;
}

const hexToRgba = (hex: string, alpha: number) => {
  if (!/^#([0-9A-Fa-f]{3}){1,2}$/.test(hex)) return hex;
  let c = hex.substring(1).split('');
  if (c.length === 3) {
    c = [c[0], c[0], c[1], c[1], c[2], c[2]];
  }
  const r = parseInt(c[0] + c[1], 16);
  const g = parseInt(c[2] + c[3], 16);
  const b = parseInt(c[4] + c[5], 16);
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
};

const InlineInput = ({ value, onChange, className, placeholder }: any) => {
  const [localValue, setLocalValue] = useState(value);
  
  useEffect(() => {
    setLocalValue(value);
  }, [value]);

  return (
    <input
      type="text"
      value={localValue}
      onChange={(e) => setLocalValue(e.target.value)}
      onBlur={() => {
        if (localValue !== value) {
          onChange(localValue);
        }
      }}
      onKeyDown={(e) => {
        if (e.key === 'Enter') e.currentTarget.blur();
      }}
      className={className}
      placeholder={placeholder}
    />
  );
};

const EntityNode = ({ id, data, selected }: EntityNodeProps) => {
  const { updateNodeColor } = useModelingStore();

  return (
    <div 
      className={`glass-node entity-node ${selected ? 'selected' : ''}`}
      style={data.color ? { background: hexToRgba(data.color, 0.85) } : {}}
    >
      <NodeToolbar isVisible={selected} position={Position.Top} offset={10}>
        <InlineColorPicker 
          color={data.color} 
          presetColors={['#1c1c23', '#27272a', '#3f3f46', '#475569']}
          onChange={(color) => updateNodeColor(id, color)}
          onCustomClick={() => useModelingStore.getState().setColorPickerOpen(true)}
        />
      </NodeToolbar>

      {/* Top and Bottom Handles for the entire Entity */}
      <Handle type="target" position={Position.Top} id="entity-target-top" className="entity-handle" />
      <Handle type="source" position={Position.Top} id="entity-source-top" className="entity-handle" />
      
      <Handle type="target" position={Position.Bottom} id="entity-target-bottom" className="entity-handle" />
      <Handle type="source" position={Position.Bottom} id="entity-source-bottom" className="entity-handle" />

      <div className="entity-header">
        <div className="entity-header-drag-handle">
          <AlignLeft size={16} className="text-muted" />
        </div>
        <InlineInput
          value={data.label}
          onChange={(val: string) => data.onChangeLabel(id, val)}
          className="entity-title-input"
          placeholder="Nome da Entidade"
        />
      </div>

      <div className="entity-attributes">
        {data.attributes.map((attr) => (
          <div key={attr.id} className="attribute-row">
            {/* Target handle for incoming connections */}
            <Handle
              type="target"
              position={Position.Left}
              id={attr.id}
              className="attribute-handle target-handle"
            />

            <div className="attribute-content">
              {attr.isPrimary && <Key size={14} className="primary-key-icon" />}
              
              <InlineInput
                value={attr.name}
                onChange={(val: string) => data.onUpdateAttribute(id, attr.id, { name: val })}
                className="attribute-name-input"
                placeholder="nome_atributo"
              />
              
              <select
                value={attr.type}
                onChange={(e) => data.onUpdateAttribute(id, attr.id, { type: e.target.value as any })}
                className="attribute-type-select"
              >
                <option value="string">String</option>
                <option value="number">Number</option>
                <option value="boolean">Boolean</option>
                <option value="date">Date</option>
                <option value="uuid">UUID</option>
                <option value="json">JSON</option>
              </select>

              <button 
                onClick={() => data.onRemoveAttribute(id, attr.id)}
                className="attribute-remove-btn"
                title="Remover atributo"
              >
                <X size={14} />
              </button>
            </div>

            {/* Source handle for outgoing connections */}
            <Handle
              type="source"
              position={Position.Right}
              id={attr.id}
              className="attribute-handle source-handle"
            />
          </div>
        ))}
      </div>

      <div className="entity-footer">
        <button 
          className="add-attribute-btn"
          onClick={() => data.onAddAttribute(id)}
        >
          <Plus size={16} /> Adicionar Atributo
        </button>
      </div>
    </div>
  );
};

export default memo(EntityNode);
