import { Paintbrush } from 'lucide-react';
import './InlineColorPicker.css';

const DEFAULT_COLORS = [
  '#6366f1', // Indigo
  '#ec4899', // Pink
  '#10b981', // Emerald
  '#f59e0b', // Amber
];

interface Props {
  color?: string;
  presetColors?: string[];
  onChange: (color: string) => void;
}

export const InlineColorPicker = ({ color, presetColors = DEFAULT_COLORS, onChange, onCustomClick, children }: Props & { children?: React.ReactNode; onCustomClick?: () => void }) => {
  const currentColor = color || 'transparent';

  return (
    <div className="inline-color-picker glass-panel nodrag nopan">
      {children}
      {children && <div className="color-divider" />}
      <button 
        className="btn-icon" 
        style={{ width: '22px', height: '22px', padding: 0, border: 'none', background: 'transparent', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
        onClick={(e) => {
          e.stopPropagation();
          onCustomClick?.();
        }}
        title="Cor Personalizada"
      >
        <Paintbrush size={14} className="color-icon" />
      </button>
      <div className="color-divider" />
      {presetColors.map(c => {
        return (
          <button
            key={c}
            className={`color-circle ${currentColor === c ? 'active' : ''}`}
            style={{ backgroundColor: c }}
            onClick={(e) => {
              e.stopPropagation();
              onChange(c);
            }}
          />
        );
      })}
    </div>
  );
};
