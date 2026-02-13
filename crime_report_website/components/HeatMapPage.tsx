
import React from 'react';

const HeatMapPage: React.FC = () => {
  return (
    <div className="relative w-full h-[calc(100vh-80px)] overflow-hidden bg-slate-100 dark:bg-slate-900 animate-in fade-in duration-700">
      {/* Background Map Mockup */}
      <img 
        className="absolute inset-0 w-full h-full object-cover filter grayscale contrast-75 brightness-110 opacity-40 dark:opacity-20 pointer-events-none" 
        src="https://lh3.googleusercontent.com/aida-public/AB6AXuAYXf9xA6D_FnVIz42zvynbtED4smIek-OcXwHmhA3ua8ri5gTqVpehv3hlbXxj6-O_S3obv2MSQROqZUCt6DzbgWny2o5Jr_FuJE_-KftImN-68_yhZGSyyCpAEpSnPUuVV3P7B0-BX5bQ0Lhful9nezJjU2hmYSJUmJL7uHue5z6j4vl9GOXs7hCCgoz_5U8KZhurJIFdHHuo4N6ZypvLDhMgs7fMBbXXiHCRijCzUHNTYkVmDZf1yU4w6bCYfBLh2da4KJ422AkP"
      />

      {/* Mock Heat Blobs */}
      <div className="absolute top-1/3 left-1/4 w-96 h-96 bg-primary/20 blur-[100px] rounded-full"></div>
      <div className="absolute top-1/2 left-1/2 w-[500px] h-[500px] bg-red-500/10 blur-[120px] rounded-full"></div>
      <div className="absolute bottom-1/4 right-1/3 w-64 h-64 bg-blue-400/20 blur-[80px] rounded-full"></div>

      {/* SOS Pulse on Map */}
      <div className="absolute top-1/2 left-1/3 z-10">
        <div className="relative">
          <div className="absolute inset-0 w-8 h-8 -top-4 -left-4 bg-red-500/30 rounded-full animate-ping"></div>
          <div className="w-4 h-4 bg-red-500 rounded-full border-2 border-white shadow-lg"></div>
          <div className="absolute top-6 left-6 glass px-3 py-1.5 rounded shadow-lg border border-red-500/30">
            <p className="text-[10px] font-bold text-red-600 dark:text-red-400">SOS: ID-8821</p>
            <p className="text-[9px] text-slate-500 whitespace-nowrap">Residential Disturbance</p>
          </div>
        </div>
      </div>

      {/* Floating UI Elements */}
      <div className="absolute top-6 left-6 z-20 flex flex-col gap-4">
        <div className="glass p-1 rounded-xl shadow-lg border border-slate-200/50 flex items-center w-96">
          <span className="material-icons ml-3 text-slate-400">search</span>
          <input className="bg-transparent border-none focus:ring-0 text-sm w-full py-3 placeholder:text-slate-400 font-display" placeholder="Search precinct, address, or ID..." type="text"/>
          <button className="bg-primary/10 text-primary px-3 py-2 rounded-lg text-xs font-bold hover:bg-primary hover:text-white transition-all mr-1">
            JUMP
          </button>
        </div>
        <div className="flex items-center gap-2 text-xs font-medium px-3">
          <span className="text-slate-500">Metropolitan</span>
          <span className="material-icons text-sm text-slate-400">chevron_right</span>
          <span className="text-primary font-bold">Downtown Precinct</span>
        </div>
      </div>

      <div className="absolute top-6 right-6 z-20 flex flex-col gap-4 w-72">
        <div className="glass rounded-xl shadow-xl p-5 border border-slate-200/50">
          <h3 className="text-xs uppercase tracking-wider font-bold text-slate-500 mb-4 flex items-center justify-between">
            Layers
            <span className="material-icons text-lg cursor-pointer">tune</span>
          </h3>
          <div className="space-y-3">
            {[
              { label: 'Crime Intensity', color: 'bg-primary', icon: 'local_fire_department', checked: true },
              { label: 'Active SOS Alerts', color: 'bg-red-500', icon: 'emergency', checked: true },
              { label: 'Patrol Units', color: 'bg-amber-500', icon: 'directions_car', checked: false },
              { label: 'CCTV Coverage', color: 'bg-emerald-500', icon: 'videocam', checked: false },
            ].map((layer) => (
              <label key={layer.label} className="flex items-center justify-between cursor-pointer">
                <div className="flex items-center gap-3">
                  <div className={`w-8 h-8 rounded ${layer.color}/10 flex items-center justify-center`}>
                    <span className={`material-icons text-lg text-${layer.color.split('-')[1]}-500`}>{layer.icon}</span>
                  </div>
                  <span className="text-sm font-semibold text-slate-700 dark:text-slate-200">{layer.label}</span>
                </div>
                <input defaultChecked={layer.checked} className="rounded text-primary focus:ring-primary h-4 w-4 bg-transparent" type="checkbox"/>
              </label>
            ))}
          </div>
        </div>

        <div className="glass rounded-xl shadow-xl p-5 border border-slate-200/50">
          <h3 className="text-xs uppercase tracking-wider font-bold text-slate-500 mb-4">Zone Health</h3>
          <div className="space-y-4">
            <div className="flex items-end justify-between">
              <div>
                <p className="text-2xl font-bold">142</p>
                <p className="text-[10px] text-slate-500 font-bold uppercase tracking-tighter leading-none">Incidents (24h)</p>
              </div>
              <div className="text-emerald-500 flex items-center gap-1">
                <span className="material-symbols-outlined text-sm">trending_down</span>
                <span className="text-xs font-bold">12%</span>
              </div>
            </div>
            <div className="w-full bg-slate-200 dark:bg-slate-700 h-1.5 rounded-full overflow-hidden">
              <div className="bg-primary h-full w-[65%]"></div>
            </div>
          </div>
        </div>
      </div>

      <div className="absolute bottom-6 left-6 right-6 z-20 flex justify-between items-end">
        <div className="glass p-4 rounded-xl shadow-xl flex items-center gap-6 border border-slate-200/50">
          <div className="flex flex-col gap-1">
            <span className="text-[10px] font-black text-slate-500 uppercase tracking-widest">Intensity Legend</span>
            <div className="flex items-center gap-3">
              <span className="text-[10px] font-bold">LOW</span>
              <div className="w-48 h-2 rounded-full bg-gradient-to-r from-blue-200 via-primary to-red-500"></div>
              <span className="text-[10px] font-bold">HIGH</span>
            </div>
          </div>
        </div>
        
        <div className="flex flex-col gap-3">
          <div className="flex flex-col glass rounded-xl shadow-xl overflow-hidden">
            <button className="p-3 hover:bg-primary/10 transition-colors border-b border-slate-200/50">
              <span className="material-icons">add</span>
            </button>
            <button className="p-3 hover:bg-primary/10 transition-colors">
              <span className="material-icons">remove</span>
            </button>
          </div>
          <button className="glass p-3 rounded-xl shadow-xl hover:bg-primary/10 transition-colors">
            <span className="material-icons">my_location</span>
          </button>
        </div>
      </div>
    </div>
  );
};

export default HeatMapPage;
