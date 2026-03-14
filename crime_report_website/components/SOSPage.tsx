import React, { useEffect, useState } from 'react';
import { API_BASE_URL } from '../constants';

interface SOSAlert {
  id: number;
  user_email: string | null;
  lat: string;
  long: string;
  status: string;
  created_at: string;
}

const formatDate = (iso: string) => {
  try {
    return new Date(iso).toLocaleString('en-IN', {
      day: '2-digit', month: 'short', year: 'numeric',
      hour: '2-digit', minute: '2-digit',
    });
  } catch { return iso; }
};

const formatRelative = (iso: string) => {
  try {
    const diff = Date.now() - new Date(iso).getTime();
    const mins = Math.floor(diff / 60000);
    if (mins < 1) return 'Just now';
    if (mins < 60) return `${mins} min${mins !== 1 ? 's' : ''} ago`;
    const hrs = Math.floor(mins / 60);
    if (hrs < 24) return `${hrs} hr${hrs !== 1 ? 's' : ''} ago`;
    return formatDate(iso);
  } catch { return iso; }
};

const statusColor = (s: string) => {
  if (s === 'Dispatched') return 'text-blue-600 bg-blue-100 dark:bg-blue-900/30 dark:text-blue-400';
  if (s === 'Resolved')   return 'text-emerald-600 bg-emerald-100 dark:bg-emerald-900/30 dark:text-emerald-400';
  if (s === 'Dismissed')  return 'text-slate-500 bg-slate-100 dark:bg-slate-800 dark:text-slate-400';
  return 'text-red-600 bg-red-100 dark:bg-red-900/30 dark:text-red-400'; // Pending
};

const SOSPage: React.FC = () => {
  const [alerts, setAlerts] = useState<SOSAlert[]>([]);
  const [loading, setLoading] = useState(true);
  const [selected, setSelected] = useState<SOSAlert | null>(null);
  const [updating, setUpdating] = useState(false);

  const fetchAlerts = () => {
    fetch(`${API_BASE_URL}/sos/all`)
      .then(r => r.json())
      .then((data: SOSAlert[]) => {
        setAlerts(data);
        // Refresh selected alert data if one is selected
        setSelected(prev => prev ? (data.find(a => a.id === prev.id) ?? data[0] ?? null) : (data[0] ?? null));
      })
      .catch(err => console.error('Failed to fetch SOS alerts:', err))
      .finally(() => setLoading(false));
  };

  useEffect(() => {
    fetchAlerts();
    const interval = setInterval(fetchAlerts, 15000);
    return () => clearInterval(interval);
  }, []);

  const updateStatus = async (newStatus: string) => {
    if (!selected || updating) return;
    setUpdating(true);
    try {
      const res = await fetch(`${API_BASE_URL}/sos/${selected.id}/status`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: newStatus }),
      });
      if (!res.ok) throw new Error('Update failed');
      const updated: SOSAlert = await res.json();
      setAlerts(prev => prev.map(a => a.id === updated.id ? updated : a));
      setSelected(updated);
    } catch (e) {
      console.error('Status update failed:', e);
    } finally {
      setUpdating(false);
    }
  };

  const today = alerts.filter(a => Date.now() - new Date(a.created_at).getTime() < 86400000).length;

  return (
    <div className="p-8 flex gap-8 h-[calc(100vh-80px)] overflow-hidden animate-in fade-in slide-in-from-bottom duration-500">

      {/* Left: Alerts Table */}
      <section className="flex-1 flex flex-col min-w-0">
        <div className="flex items-start justify-between mb-6">
          <div>
            <h1 className="text-2xl font-bold text-slate-900 dark:text-white flex items-center gap-2">
              <span className="w-3 h-3 rounded-full bg-red-500 animate-pulse inline-block"></span>
              SOS Alerts
            </h1>
            <p className="text-sm text-slate-500 dark:text-slate-400 mt-1">
              Live emergency signals — auto-refreshes every 15 seconds
            </p>
          </div>
          <div className="flex gap-3">
            <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-xl px-4 py-3 text-center">
              <p className="text-2xl font-bold text-red-600 dark:text-red-400">{today}</p>
              <p className="text-[10px] font-bold text-red-400 uppercase tracking-wider">Today</p>
            </div>
            <div className="bg-slate-50 dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-xl px-4 py-3 text-center">
              <p className="text-2xl font-bold text-slate-800 dark:text-white">{alerts.length}</p>
              <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">Total</p>
            </div>
          </div>
        </div>

        <div className="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 overflow-hidden flex-1 flex flex-col shadow-sm">
          <div className="overflow-y-auto custom-scrollbar flex-1">
            {loading ? (
              <div className="flex items-center justify-center py-32 text-slate-400">
                <span className="material-icons animate-spin text-3xl mr-2">refresh</span>
                <span>Loading SOS alerts…</span>
              </div>
            ) : alerts.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-32 text-slate-400">
                <span className="material-icons text-5xl mb-3 text-emerald-400">verified_user</span>
                <p className="text-lg font-semibold text-emerald-600 dark:text-emerald-400">All Clear</p>
                <p className="text-sm mt-1">No SOS alerts have been triggered.</p>
              </div>
            ) : (
              <table className="w-full text-left">
                <thead className="bg-slate-50 dark:bg-slate-800 border-b border-slate-200 dark:border-slate-800 sticky top-0 z-10">
                  <tr>
                    <th className="px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider">Alert ID</th>
                    <th className="px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider">Triggered By</th>
                    <th className="px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider">Coordinates</th>
                    <th className="px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider">Status</th>
                    <th className="px-6 py-4 text-xs font-bold text-slate-500 uppercase tracking-wider">Time</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                  {alerts.map((alert) => {
                    const isRecent = Date.now() - new Date(alert.created_at).getTime() < 3600000;
                    return (
                      <tr
                        key={alert.id}
                        onClick={() => setSelected(alert)}
                        className={`cursor-pointer transition-colors hover:bg-red-50 dark:hover:bg-red-900/10 ${
                          selected?.id === alert.id ? 'bg-red-50 dark:bg-red-900/10 border-l-4 border-l-red-500' : ''
                        }`}
                      >
                        <td className="px-6 py-4">
                          <div className="flex items-center gap-2">
                            {isRecent && alert.status === 'Pending' && (
                              <span className="w-2 h-2 rounded-full bg-red-500 animate-ping flex-shrink-0"></span>
                            )}
                            <span className="font-mono text-sm font-bold text-red-600 dark:text-red-400">
                              #SOS-{String(alert.id).padStart(4, '0')}
                            </span>
                          </div>
                        </td>
                        <td className="px-6 py-4 text-sm text-slate-700 dark:text-slate-300">
                          {alert.user_email ?? 'Unknown'}
                        </td>
                        <td className="px-6 py-4">
                          <span className="font-mono text-xs text-slate-500">
                            {parseFloat(alert.lat).toFixed(4)}, {parseFloat(alert.long).toFixed(4)}
                          </span>
                        </td>
                        <td className="px-6 py-4">
                          <span className={`inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-xs font-bold ${statusColor(alert.status)}`}>
                            <span className={`w-1.5 h-1.5 rounded-full ${alert.status === 'Pending' ? 'bg-red-500 animate-pulse' : alert.status === 'Dispatched' ? 'bg-blue-500' : alert.status === 'Resolved' ? 'bg-emerald-500' : 'bg-slate-400'}`}></span>
                            {alert.status}
                          </span>
                        </td>
                        <td className="px-6 py-4 text-sm text-slate-500">
                          {formatRelative(alert.created_at)}
                        </td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            )}
          </div>
          <div className="p-4 border-t border-slate-200 dark:border-slate-800 bg-slate-50 dark:bg-slate-800/50 flex items-center gap-2">
            <span className="w-2 h-2 rounded-full bg-red-500 animate-pulse"></span>
            <span className="text-xs text-slate-500">
              {loading ? '—' : `${alerts.length} alert${alerts.length !== 1 ? 's' : ''} · auto-refreshing`}
            </span>
          </div>
        </div>
      </section>

      {/* Right: Detail Panel */}
      {selected && (
        <section className="w-[400px] flex flex-col gap-4 animate-in slide-in-from-right duration-300">
          {/* Alert Card */}
          <div className="bg-white dark:bg-slate-900 rounded-xl border-2 border-red-200 dark:border-red-900/50 shadow-lg overflow-hidden">
            <div className="bg-red-500 px-6 py-4 flex items-center justify-between">
              <div className="flex items-center gap-3">
                <span className="material-icons text-white text-2xl">emergency</span>
                <div>
                  <p className="text-white font-bold text-lg leading-none">
                    #SOS-{String(selected.id).padStart(4, '0')}
                  </p>
                  <p className="text-red-100 text-xs mt-0.5">Emergency Alert</p>
                </div>
              </div>
              <span className={`px-3 py-1 rounded-full text-xs font-bold ${statusColor(selected.status)}`}>
                {selected.status}
              </span>
            </div>

            <div className="p-5 space-y-3">
              <div className="flex items-center gap-3 p-3 bg-slate-50 dark:bg-slate-800 rounded-lg">
                <div className="w-9 h-9 rounded-full bg-red-100 dark:bg-red-900/30 flex items-center justify-center flex-shrink-0">
                  <span className="material-icons text-red-500 text-base">person</span>
                </div>
                <div>
                  <p className="text-[10px] font-bold text-slate-400 uppercase">Triggered By</p>
                  <p className="text-sm font-semibold text-slate-800 dark:text-white">{selected.user_email ?? 'Unknown'}</p>
                </div>
              </div>

              <div className="flex items-center gap-3 p-3 bg-slate-50 dark:bg-slate-800 rounded-lg">
                <div className="w-9 h-9 rounded-full bg-amber-100 dark:bg-amber-900/30 flex items-center justify-center flex-shrink-0">
                  <span className="material-icons text-amber-500 text-base">schedule</span>
                </div>
                <div>
                  <p className="text-[10px] font-bold text-slate-400 uppercase">Time of Alert</p>
                  <p className="text-sm font-semibold text-slate-800 dark:text-white">{formatDate(selected.created_at)}</p>
                  <p className="text-xs text-slate-400">{formatRelative(selected.created_at)}</p>
                </div>
              </div>

              <div className="flex items-center gap-3 p-3 bg-slate-50 dark:bg-slate-800 rounded-lg">
                <div className="w-9 h-9 rounded-full bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center flex-shrink-0">
                  <span className="material-icons text-blue-500 text-base">location_on</span>
                </div>
                <div>
                  <p className="text-[10px] font-bold text-slate-400 uppercase">GPS Coordinates</p>
                  <p className="font-mono text-sm font-semibold text-slate-800 dark:text-white">
                    {parseFloat(selected.lat).toFixed(6)}, {parseFloat(selected.long).toFixed(6)}
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* Status Update */}
          <div className="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 p-5 shadow-sm">
            <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-3">Update Status</p>
            <div className="grid grid-cols-2 gap-2">
              {[
                { label: 'Dispatch Unit', status: 'Dispatched', icon: 'local_police', color: 'bg-blue-600 hover:bg-blue-700 shadow-blue-500/20' },
                { label: 'Mark Resolved', status: 'Resolved',   icon: 'check_circle', color: 'bg-emerald-600 hover:bg-emerald-700 shadow-emerald-500/20' },
                { label: 'Set Pending',   status: 'Pending',    icon: 'hourglass_top', color: 'bg-red-600 hover:bg-red-700 shadow-red-500/20' },
                { label: 'Dismiss',       status: 'Dismissed',  icon: 'cancel',        color: 'bg-slate-500 hover:bg-slate-600 shadow-slate-400/20' },
              ].map(btn => (
                <button
                  key={btn.status}
                  disabled={updating || selected.status === btn.status}
                  onClick={() => updateStatus(btn.status)}
                  className={`py-2.5 ${btn.color} disabled:opacity-40 disabled:cursor-not-allowed text-white text-xs font-bold rounded-lg flex items-center justify-center gap-1.5 transition-all active:scale-95 shadow-md`}
                >
                  <span className="material-icons text-sm">{btn.icon}</span>
                  {btn.label}
                </button>
              ))}
            </div>
            {updating && (
              <p className="text-center text-xs text-slate-400 animate-pulse mt-2 flex items-center justify-center gap-1">
                <span className="material-icons text-xs animate-spin">refresh</span>
                Updating…
              </p>
            )}
          </div>

          {/* Open Map */}
          <a
            href={`https://www.google.com/maps?q=${selected.lat},${selected.long}`}
            target="_blank"
            rel="noopener noreferrer"
            className="w-full py-3 bg-blue-600 hover:bg-blue-700 text-white font-bold rounded-xl flex items-center justify-center gap-2 transition-colors shadow-lg shadow-blue-500/20"
          >
            <span className="material-icons">open_in_new</span>
            Open in Google Maps
          </a>
        </section>
      )}
    </div>
  );
};

export default SOSPage;
