import React, { useState, useEffect, useRef } from 'react';
import { fetchNui } from "@/utils/fetchNui";

interface TimedProgressProps {
  duration: number;  
  label?: string;
  color?: string;
  onComplete: (success: boolean) => void;
  isFading: boolean;
}

const TimedProgress: React.FC<TimedProgressProps> = ({
  duration,
  label,
  color = 'hsl(var(--primary))',
  onComplete,
  isFading
}) => {
  const [progress, setProgress] = useState(0);
  const [isComplete, setIsComplete] = useState(false);
  const lastProgress = useRef(0);

  useEffect(() => {
    if (isFading) {
      return; 
    }

    const startTime = Date.now();
    let animationFrame: number;

    const updateProgress = () => {
      const elapsed = Date.now() - startTime;
      const newProgress = Math.min((elapsed / duration) * 100, 100);
      
      setProgress(newProgress);
      lastProgress.current = newProgress;

      if (newProgress < 100) {
        animationFrame = requestAnimationFrame(updateProgress);
      } else {
        setIsComplete(true);
        onComplete(true);
      }
    };

    animationFrame = requestAnimationFrame(updateProgress);

    return () => {
      cancelAnimationFrame(animationFrame);
      if (!isComplete && !isFading) {
        onComplete(false);
      }
    };
  }, [duration, onComplete, isFading]);

  const displayProgress = isFading ? lastProgress.current : progress;

  return (
    <div className="relative w-64">
      <div className="absolute inset-0 bg-background/95 border border-border/40 h-6">
        <div className="absolute -top-px -left-px">
          <div className="absolute top-0 left-0 w-3 h-[1px]" style={{ backgroundColor: color }} />
          <div className="absolute top-0 left-0 w-[1px] h-3" style={{ backgroundColor: color }} />
        </div>
        <div className="absolute -top-px -right-px">
          <div className="absolute top-0 right-0 w-3 h-[1px]" style={{ backgroundColor: color }} />
          <div className="absolute top-0 right-0 w-[1px] h-3" style={{ backgroundColor: color }} />
        </div>
        <div className="absolute -bottom-px -left-px">
          <div className="absolute bottom-0 left-0 w-3 h-[1px]" style={{ backgroundColor: color }} />
          <div className="absolute bottom-0 left-0 w-[1px] h-3" style={{ backgroundColor: color }} />
        </div>
        <div className="absolute -bottom-px -right-px">
          <div className="absolute bottom-0 right-0 w-3 h-[1px]" style={{ backgroundColor: color }} />
          <div className="absolute bottom-0 right-0 w-[1px] h-3" style={{ backgroundColor: color }} />
        </div>

        <div 
          className="absolute top-[1px] left-[1px] bottom-[1px] transition-all duration-100 ease-linear"
          style={{
            width: `calc(${displayProgress}% - 1px)`,
            backgroundColor: color,
            opacity: 0.15
          }}
        />

        <div 
          className="absolute top-0 bottom-0 w-[2px] transition-all duration-100 ease-linear"
          style={{
            left: `${displayProgress}%`,
            backgroundColor: color,
            boxShadow: `0 0 10px ${color}`,
            transform: 'translateX(-50%)',
            display: displayProgress > 0 ? 'block' : 'none'
          }}
        />
        <div className="absolute inset-0 flex items-center justify-center">
          <span className="text-xs font-mono uppercase tracking-wider text-foreground/90">
            {label}
          </span>
        </div>
      </div>
    </div>
  );
};

const ProgressBarSystem: React.FC = () => {
  const [activeProgress, setActiveProgress] = useState<{
    duration: number;
    label?: string;
    color?: string;
  } | null>(null);
  const [isVisible, setIsVisible] = useState(false);
  const [isFading, setIsFading] = useState(false);

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      if (event.data.action === 'startProgress') {
        setIsFading(false);
        setActiveProgress(event.data.data);
        setIsVisible(true);
      } else if (event.data.action === 'cancelProgress') {
        setIsFading(true);
        setIsVisible(false);
        setTimeout(() => {
          setActiveProgress(null);
          setIsFading(false);
        }, 150);
      }
    };

    window.addEventListener('message', handleMessage);
    return () => window.removeEventListener('message', handleMessage);
  }, []);

  const handleComplete = (success: boolean) => {
    fetchNui('progressComplete', { success });
    setIsFading(true);
    setIsVisible(false);
    setTimeout(() => {
      setActiveProgress(null);
      setIsFading(false);
    }, 150);
  };

  if (!activeProgress) return null;

  return (
    <div 
      className="fixed bottom-24 left-1/2 -translate-x-1/2 pointer-events-none"
      style={{
        opacity: isVisible ? 1 : 0,
        transition: 'opacity 150ms ease-out'
      }}
    >
      <TimedProgress 
        {...activeProgress} 
        onComplete={handleComplete}
        isFading={isFading}
      />
    </div>
  );
};

export default ProgressBarSystem;