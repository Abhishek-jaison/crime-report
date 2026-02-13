
import React from 'react';

interface SidebarProps {
  activeTab: string;
  setActiveTab: (tab: string) => void;
}

const Sidebar: React.FC<SidebarProps> = ({ activeTab, setActiveTab }) => {
  const navItems = [
    { id: 'dashboard', icon: 'dashboard', label: 'Dashboard' },
    { id: 'reports', icon: 'assignment', label: 'Reports' },
    { id: 'heatmap', icon: 'map', label: 'Heat Map' },
    { id: 'sos', icon: 'emergency', label: 'SOS Alerts', badge: true },
    { id: 'users', icon: 'people', label: 'Users' },
    { id: 'settings', icon: 'settings', label: 'Settings' },
  ];

  return (
    <aside className="w-64 bg-white dark:bg-slate-900 border-r border-slate-200 dark:border-slate-800 flex flex-col fixed h-full z-20">
      <div className="p-6 flex items-center gap-3">
        <div className="w-10 h-10 bg-primary rounded-lg flex items-center justify-center">
          <span className="material-icons text-white">security</span>
        </div>
        <h1 className="text-xl font-bold tracking-tight text-slate-800 dark:text-white leading-tight">GuardianOS</h1>
      </div>
      
      <nav className="flex-1 px-4 py-4 space-y-1">
        {navItems.map((item) => (
          <button
            key={item.id}
            onClick={() => setActiveTab(item.id)}
            className={`w-full flex items-center gap-3 px-4 py-3 rounded-lg transition-all relative ${
              activeTab === item.id
                ? 'bg-primary text-white shadow-md shadow-primary/20'
                : 'text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800'
            }`}
          >
            <span className="material-icons">{item.icon}</span>
            <span className="font-medium">{item.label}</span>
            {item.badge && (
              <span className="absolute right-4 w-2 h-2 bg-red-500 rounded-full animate-pulse"></span>
            )}
          </button>
        ))}
      </nav>

      <div className="p-4 border-t border-slate-100 dark:border-slate-800">
        <div className="bg-primary/5 dark:bg-primary/10 p-4 rounded-xl flex items-center gap-3">
          <img 
            alt="User Profile" 
            className="w-10 h-10 rounded-full object-cover ring-2 ring-primary/20" 
            src="https://lh3.googleusercontent.com/aida-public/AB6AXuAJZTTBg9y8ouF9r9JutN65Mq8M6KzU55gUd1HtXhelN46qL5kuppIhK7ZyNacLlkSsuFUrKg9rqpKpdIQInvG8GM0_VSaxQGbu4cyIdsc2NVogl0J2_Gi5HJgmSfv9NvhOyrc6hkMn1uP_rCTh0mCj4nx_7YwUuKAr5yWp0Wd4XvnMuPFyaaeP215RKH5p11xKNLt90leFYHJ_odh2XlIIglRzFXQVVXWUkWfyAkzf3TvRddBYW1JniaR9Q20STI8PKoKOSpbW7bGh"
          />
          <div className="overflow-hidden">
            <p className="text-sm font-semibold truncate text-slate-800 dark:text-white">Insp. James Miller</p>
            <p className="text-xs text-slate-500 dark:text-slate-400 truncate">Senior Admin</p>
          </div>
        </div>
      </div>
    </aside>
  );
};

export default Sidebar;
