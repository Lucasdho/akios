import { BaseEdge, EdgeToolbar, getSmoothStepPath } from '@xyflow/react';
import type { EdgeProps } from '@xyflow/react';
import { Baseline, ArrowRight, ArrowLeftRight, Minus } from 'lucide-react';
import { useModelingStore } from '../../store/useModelingStore';
import { InlineColorPicker } from '../Toolbar/InlineColorPicker';

export default function CustomEdge(props: EdgeProps) {
  const {
    id,
    sourceX,
    sourceY,
    targetX,
    targetY,
    sourcePosition,
    targetPosition,
    style,
    markerEnd,
    markerStart,
    selected,
    data
  } = props;
  const { updateEdgeWidth, updateEdgeColor, updateEdgeMarker } = useModelingStore();
  const [edgePath, labelX, labelY] = getSmoothStepPath({
    sourceX,
    sourceY,
    sourcePosition,
    targetX,
    targetY,
    targetPosition,
  });

  const handleWidthCycle = () => {
    const currentWidth = style?.strokeWidth ? Number(style.strokeWidth) : 2;
    // Cycle: 2 -> 4 -> 6 -> 2
    const nextWidth = currentWidth >= 6 ? 2 : currentWidth + 2;
    updateEdgeWidth(id, nextWidth);
  };

  const currentMarker = data?.markerType as string | undefined;

  const handleMarkerCycle = () => {
    if (!currentMarker) {
      updateEdgeMarker(id, 'arrow');
    } else if (currentMarker === 'arrow') {
      updateEdgeMarker(id, 'bidirectional');
    } else {
      updateEdgeMarker(id, undefined);
    }
  };

  const renderMarkerIcon = () => {
    if (!currentMarker) return <Minus size={14} />;
    if (currentMarker === 'arrow') return <ArrowRight size={14} />;
    if (currentMarker === 'bidirectional') return <ArrowLeftRight size={14} />;
    return <Minus size={14} />;
  };

  return (
    <>
      <BaseEdge path={edgePath} markerEnd={markerEnd} markerStart={markerStart} style={style} />
      
      <EdgeToolbar 
        edgeId={id} 
        x={labelX}
        y={labelY - 12}
        isVisible={selected} 
      >
        <InlineColorPicker 
          color={style?.stroke} 
          onChange={(color) => updateEdgeColor(id, color)}
          onCustomClick={() => useModelingStore.getState().setColorPickerOpen(true)}
        >
          <button 
            className="btn-icon" 
            style={{ width: '22px', height: '22px', padding: 0, border: 'none', background: 'transparent', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
            onClick={handleWidthCycle}
            title="Mudar Espessura"
          >
            <Baseline size={14} />
          </button>
          <div style={{ width: 1, height: 14, background: 'var(--border-color)', margin: '0 2px' }} />
          <button 
            className="btn-icon" 
            style={{ width: '22px', height: '22px', padding: 0, border: 'none', background: 'transparent', display: 'flex', alignItems: 'center', justifyContent: 'center' }}
            onClick={handleMarkerCycle}
            title="Mudar Ponta da Seta (UML)"
          >
            {renderMarkerIcon()}
          </button>
        </InlineColorPicker>
      </EdgeToolbar>
    </>
  );
}
