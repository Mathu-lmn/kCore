export interface Item {
    id: string;
    src: string;
    size: { width: number; height: number };
    alt: string;
    position: { x: number; y: number };
    rarity?: 'common' | 'rare' | 'epic' | 'legendary';
    inventoryId: string;
  }
  
  export interface InventoryData {
    id: string;
    name: string;
    rows: number;
    columns: number;
  }
  
  export const rarityColors = {
    common: {
      border: '#3b82f6',
      background: 'rgba(59, 130, 246, 0.1)'
    },
    rare: {
      border: '#8b5cf6',
      background: 'rgba(139, 92, 246, 0.1)'
    },
    epic: {
      border: '#d946ef',
      background: 'rgba(217, 70, 239, 0.1)'
    },
    legendary: {
      border: '#fbbf24',
      background: 'rgba(251, 191, 36, 0.1)'
    }
  };