
import React, { useState } from 'react';
import Sidebar from './components/Sidebar';
import TopHeader from './components/TopHeader';
import Dashboard from './components/Dashboard';
import ReportsPage from './components/ReportsPage';
import HeatMapPage from './components/HeatMapPage';
import UsersPage from './components/UsersPage';
import SettingsPage from './components/SettingsPage';

const App: React.FC = () => {
  const [activeTab, setActiveTab] = useState<string>('dashboard');

  const renderContent = () => {
    switch (activeTab) {
      case 'dashboard':
        return <Dashboard />;
      case 'reports':
        return <ReportsPage />;
      case 'heatmap':
        return <HeatMapPage />;
      case 'users':
        return <UsersPage />;
      case 'settings':
        return <SettingsPage />;
      default:
        return <Dashboard />;
    }
  };

  const getPageTitle = () => {
    switch (activeTab) {
      case 'dashboard': return 'Dashboard Overview';
      case 'reports': return 'Reports Management';
      case 'heatmap': return 'Incident Heat Map';
      case 'sos': return 'SOS Alerts Monitoring';
      case 'users': return 'User Database';
      case 'settings': return 'System Settings';
      default: return 'GuardianOS';
    }
  };

  return (
    <div className="flex min-h-screen">
      <Sidebar activeTab={activeTab} setActiveTab={setActiveTab} />
      
      <main className="flex-1 lg:ml-64 bg-background-light dark:bg-background-dark min-h-screen flex flex-col">
        <TopHeader title={getPageTitle()} />
        <div className="flex-1 overflow-y-auto">
          {renderContent()}
        </div>
      </main>
    </div>
  );
};

export default App;
