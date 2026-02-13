
import React from 'react';

const SettingsPage: React.FC = () => {
  return (
    <div className="max-w-5xl mx-auto px-4 py-8 sm:px-6 lg:px-8 animate-in fade-in duration-500">
      <div className="mb-8 border-b border-slate-200 dark:border-slate-800 pb-6 flex flex-wrap justify-between items-end gap-4">
        <div>
          <h2 className="text-3xl font-bold text-slate-900 dark:text-white">System Settings</h2>
          <p className="mt-1 text-slate-500">Manage your administrative profile and system preferences.</p>
        </div>
        <div className="text-sm text-slate-400 italic">
          Last login: Oct 24, 2023 at 08:42 AM (10.0.1.25)
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
        <div className="md:col-span-1 space-y-2">
          <nav className="space-y-1">
            <button className="w-full flex items-center gap-3 px-4 py-3 bg-primary text-white rounded-lg font-medium">
              <span className="material-icons text-[20px]">manage_accounts</span>
              <span>Profile Information</span>
            </button>
            <button className="w-full flex items-center gap-3 px-4 py-3 text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg transition-colors font-medium">
              <span className="material-icons text-[20px]">notifications_active</span>
              <span>Notification Preferences</span>
            </button>
            <button className="w-full flex items-center gap-3 px-4 py-3 text-slate-600 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-800 rounded-lg transition-colors font-medium">
              <span className="material-icons text-[20px]">security</span>
              <span>Security & Access</span>
            </button>
          </nav>
          <div className="pt-8">
            <button className="w-full flex items-center justify-center gap-2 px-4 py-3 bg-red-50 dark:bg-red-900/10 text-red-600 border border-red-200 dark:border-red-900/20 rounded-lg font-bold hover:bg-red-100 transition-all">
              <span className="material-icons text-[20px]">logout</span>
              <span>Sign Out</span>
            </button>
            <p className="text-[11px] text-center mt-4 text-slate-400">Secure session will be terminated immediately.</p>
          </div>
        </div>

        <div className="md:col-span-2 space-y-8">
          <section className="bg-white dark:bg-slate-900 rounded-xl shadow-sm border border-slate-200 dark:border-slate-800 overflow-hidden">
            <div className="p-6 border-b border-slate-100 dark:border-slate-800 flex justify-between items-center">
              <h3 className="text-lg font-bold">Admin Profile</h3>
              <button className="text-xs font-bold text-primary flex items-center gap-1 hover:underline uppercase">
                <span className="material-icons text-sm">edit</span> Edit Profile
              </button>
            </div>
            <div className="p-6 grid grid-cols-1 sm:grid-cols-2 gap-6">
              <div>
                <label className="block text-xs font-bold text-slate-500 uppercase mb-1">Full Name</label>
                <div className="bg-slate-50 dark:bg-slate-800/50 p-3 rounded border border-slate-200 dark:border-slate-700 text-sm font-medium">
                  Insp. James Miller
                </div>
              </div>
              <div>
                <label className="block text-xs font-bold text-slate-500 uppercase mb-1">Administrative Role</label>
                <div className="bg-slate-50 dark:bg-slate-800/50 p-3 rounded border border-slate-200 dark:border-slate-700 text-sm font-medium flex items-center gap-2">
                  <span className="w-2 h-2 bg-green-500 rounded-full"></span>
                  Senior Dispatcher / System Admin
                </div>
              </div>
            </div>
          </section>

          <section className="bg-white dark:bg-slate-900 rounded-xl shadow-sm border border-slate-200 dark:border-slate-800 overflow-hidden">
            <div className="p-6 border-b border-slate-100 dark:border-slate-800 flex justify-between items-center">
              <h3 className="text-lg font-bold">Notification Preferences</h3>
              <span className="text-[10px] bg-primary/10 text-primary px-2 py-1 rounded font-bold uppercase tracking-wider">Active</span>
            </div>
            <div className="p-6 space-y-6">
              {[
                { title: 'Desktop SOS Alerts', desc: 'Receive immediate browser notifications for incoming high-priority signals.', checked: true },
                { title: 'Crime Report Email Digest', desc: 'Receive automated summaries of all crime reports within your jurisdiction.', checked: true },
                { title: 'SMS System Alerts', desc: 'Text messages for critical system maintenance or emergency status.', checked: false },
              ].map((notif, i) => (
                <div key={notif.title} className="space-y-6">
                  <div className="flex items-start justify-between">
                    <div className="flex-1 pr-4">
                      <h4 className="text-sm font-bold">{notif.title}</h4>
                      <p className="text-xs text-slate-500 mt-1">{notif.desc}</p>
                    </div>
                    <div className="relative inline-flex items-center cursor-pointer">
                      <input defaultChecked={notif.checked} className="sr-only peer" type="checkbox"/>
                      <div className="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer dark:bg-slate-700 peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all dark:border-gray-600 peer-checked:bg-primary"></div>
                    </div>
                  </div>
                  {i !== 2 && <div className="h-[1px] bg-slate-100 dark:bg-slate-800 w-full"></div>}
                </div>
              ))}
            </div>
          </section>

          <div className="flex items-center justify-between pt-4">
            <button className="px-6 py-2 border border-slate-300 dark:border-slate-700 text-slate-600 dark:text-slate-400 font-bold rounded-lg hover:bg-slate-100 transition-colors text-sm">
              Reset to Defaults
            </button>
            <button className="px-8 py-2 bg-primary text-white font-bold rounded-lg shadow-lg shadow-primary/30 hover:bg-primary/90 transition-all text-sm uppercase tracking-wide">
              Save Preferences
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};

export default SettingsPage;
