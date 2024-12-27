import { useState, useEffect } from "react";
import { debugData } from "../utils/debugData";
import ProgressBarSystem from "./ui/progressbar";


debugData([
  {
    action: "setVisible",
    data: true,
  },
]);

const App: React.FC = () => {
  const [visible, setVisible] = useState(false);

  useEffect(() => {
    const handleMessage = (event: MessageEvent) => {
      if (event.data.action === "setVisible") {
        setVisible(event.data.data);
      }
    };

    window.addEventListener('message', handleMessage);
    return () => window.removeEventListener('message', handleMessage);
  }, []);

  return (
    <div 
    className="nui-wrapper w-full h-full"
    style={{ 
      pointerEvents: visible ? 'auto' : 'none',
    }}
  >
    <ProgressBarSystem />
  </div>
  );
};

export default App;