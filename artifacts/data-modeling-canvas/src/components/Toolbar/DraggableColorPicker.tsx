import { useState, useRef, useEffect } from 'react';
import { HexColorPicker, HexColorInput } from 'react-colorful';
import { X, GripHorizontal } from 'lucide-react';
import './DraggableColorPicker.css';

interface Props {
  color: string;
  onChange: (color: string) => void;
  onClose: () => void;
}

export const DraggableColorPicker = ({ color, onChange, onClose }: Props) => {
  const [position, setPosition] = useState({ x: window.innerWidth / 2 - 100, y: window.innerHeight / 2 - 150 });
  const [isDragging, setIsDragging] = useState(false);
  const dragRef = useRef<{ startX: number; startY: number; initialX: number; initialY: number } | null>(null);

  const handleMouseDown = (e: React.MouseEvent) => {
    setIsDragging(true);
    dragRef.current = {
      startX: e.clientX,
      startY: e.clientY,
      initialX: position.x,
      initialY: position.y
    };
  };

  useEffect(() => {
    const handleMouseMove = (e: MouseEvent) => {
      if (!isDragging || !dragRef.current) return;
      const dx = e.clientX - dragRef.current.startX;
      const dy = e.clientY - dragRef.current.startY;
      setPosition({
        x: Math.max(0, Math.min(window.innerWidth - 200, dragRef.current.initialX + dx)),
        y: Math.max(0, Math.min(window.innerHeight - 300, dragRef.current.initialY + dy))
      });
    };
    
    const handleMouseUp = () => setIsDragging(false);

    if (isDragging) {
      window.addEventListener('mousemove', handleMouseMove);
      window.addEventListener('mouseup', handleMouseUp);
    }

    return () => {
      window.removeEventListener('mousemove', handleMouseMove);
      window.removeEventListener('mouseup', handleMouseUp);
    };
  }, [isDragging]);

  return (
    <div 
      className="draggable-color-picker glass-panel nodrag nopan"
      style={{ left: position.x, top: position.y }}
    >
      <div className="picker-header" onMouseDown={handleMouseDown}>
        <GripHorizontal size={14} className="drag-handle" />
        <span className="picker-title">Cor Personalizada</span>
        <button onClick={onClose} className="close-btn"><X size={14} /></button>
      </div>
      <div className="picker-body">
        <HexColorPicker color={color?.startsWith('#') ? color : '#6366f1'} onChange={onChange} />
        <div className="hex-input-container">
          <span className="hex-prefix">#</span>
          <HexColorInput 
            color={color?.startsWith('#') ? color : '#6366f1'} 
            onChange={onChange} 
            className="custom-hex-input" 
            prefixed={false} 
          />
        </div>
      </div>
    </div>
  );
};
