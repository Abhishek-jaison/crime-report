
import React, { useEffect, useState } from 'react';
import axios from 'axios';
import { API_BASE_URL, MOCK_ACTIVITY } from '../constants'; // Keeping mock activity for now if not replaced
import { Report } from '../types'; // Assuming Report type exists

interface DashboardStats {
  totalReports: number;
  todayReports: number;
  sosAlerts: number;
  highPriority: number; // Placeholder or calculate
}

const Dashboard: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats>({
    totalReports: 0,
    todayReports: 0,
    sosAlerts: 0,
    highPriority: 0,
  });

  const [recentReports, setRecentReports] = useState<any[]>([]); // Using any for flexibility with backend response
  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    const fetchData = async () => {
      try {
        // Fetch Complaint Stats
        const complaintStatsRes = await axios.get(`${API_BASE_URL}/complaints/stats`);
        const { total_complaints, today_complaints } = complaintStatsRes.data;

        // Fetch SOS Stats
        const sosStatsRes = await axios.get(`${API_BASE_URL}/sos/stats`);
        const { total_alerts, today_alerts } = sosStatsRes.data;

        // Fetch Recent Reports
        const recentReportsRes = await axios.get(`${API_BASE_URL}/complaints/recent`);

        setStats({
          totalReports: total_complaints,
          todayReports: today_complaints,
          sosAlerts: today_alerts, // Using today's SOS alerts as the "Live" number makes sense
          highPriority: 0, // Not implemented yet
        });

        setRecentReports(recentReportsRes.data);
      } catch (error) {
        console.error("Error fetching dashboard data:", error);
      } finally {
        setLoading(false);
      }
    };

    fetchData();
    // Refresh every 30 seconds
    const interval = setInterval(fetchData, 30000);
    return () => clearInterval(interval);
  }, []);

  if (loading) {
    return <div className="p-8 text-center">Loading dashboard data...</div>;
  }

  return (
    <div className="p-8 space-y-8 animate-in fade-in duration-500">
      <div>
        <h2 className="text-2xl font-bold text-slate-800 dark:text-white">System Overview</h2>
        <p className="text-slate-500 dark:text-slate-400 mt-1">Real-time monitoring of civic safety and incident response.</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div className="bg-white dark:bg-slate-900 p-6 rounded-xl border border-slate-200 dark:border-slate-800 hover:shadow-lg transition-all cursor-default">
          <div className="flex items-center justify-between mb-4">
            <div className="w-12 h-12 bg-primary/10 dark:bg-primary/20 text-primary rounded-xl flex items-center justify-center">
              <span className="material-icons">analytics</span>
            </div>
            {/* Trend placeholder */}
            <span className="text-xs font-bold text-emerald-500 flex items-center gap-1">
              <span className="material-icons text-xs">trending_up</span> Live
            </span>
          </div>
          <h3 className="text-slate-500 dark:text-slate-400 text-sm font-medium">Total Reports</h3>
          <p className="text-3xl font-bold text-slate-800 dark:text-white mt-1">{stats.totalReports}</p>
        </div>

        <div className="bg-white dark:bg-slate-900 p-6 rounded-xl border border-slate-200 dark:border-slate-800 hover:shadow-lg transition-all cursor-default">
          <div className="flex items-center justify-between mb-4">
            <div className="w-12 h-12 bg-blue-500/10 dark:bg-blue-500/20 text-blue-500 rounded-xl flex items-center justify-center">
              <span className="material-icons">event</span>
            </div>
            <span className="text-xs font-bold text-slate-400">Past 24h</span>
          </div>
          <h3 className="text-slate-500 dark:text-slate-400 text-sm font-medium">Reports Today</h3>
          <p className="text-3xl font-bold text-slate-800 dark:text-white mt-1">{stats.todayReports}</p>
        </div>

        <div className="bg-white dark:bg-slate-900 p-6 rounded-xl border border-slate-200 dark:border-slate-800 hover:shadow-lg transition-all cursor-default">
          <div className="flex items-center justify-between mb-4">
            <div className="w-12 h-12 bg-orange-500/10 dark:bg-orange-500/20 text-orange-500 rounded-xl flex items-center justify-center">
              <span className="material-icons">priority_high</span>
            </div>
          </div>
          <h3 className="text-slate-500 dark:text-slate-400 text-sm font-medium">High Priority</h3>
          <p className="text-3xl font-bold text-slate-800 dark:text-white mt-1">--</p>
        </div>

        <div className="bg-white dark:bg-slate-900 p-6 rounded-xl border-2 border-red-500/20 dark:border-red-500/40 hover:shadow-lg transition-all relative overflow-hidden group cursor-default">
          <div className="absolute top-0 right-0 w-24 h-24 -mr-8 -mt-8 bg-red-500/5 dark:bg-red-500/10 rounded-full group-hover:scale-150 transition-transform"></div>
          <div className="flex items-center justify-between mb-4">
            <div className="w-12 h-12 bg-red-500 text-white rounded-xl flex items-center justify-center animate-pulse">
              <span className="material-icons">emergency</span>
            </div>
            <span className="text-xs font-bold text-red-500">Live Today</span>
          </div>
          <h3 className="text-slate-500 dark:text-slate-400 text-sm font-medium">SOS Alerts</h3>
          <p className="text-3xl font-bold text-red-600 dark:text-red-400 mt-1">{stats.sosAlerts}</p>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Recent Reports Preview */}
        <div className="lg:col-span-2 bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 overflow-hidden shadow-sm">
          <div className="p-6 border-b border-slate-200 dark:border-slate-800 flex items-center justify-between">
            <h3 className="text-lg font-bold text-slate-800 dark:text-white">Recent Reports</h3>
            <button className="text-primary text-sm font-bold hover:underline">View All</button>
          </div>
          <div className="overflow-x-auto">
            <table className="w-full text-left">
              <thead className="bg-slate-50 dark:bg-slate-800/50">
                <tr>
                  <th className="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Report ID</th>
                  <th className="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Title/Type</th>
                  <th className="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                {recentReports.map((report) => (
                  <tr key={report.id} className="hover:bg-slate-50 dark:hover:bg-slate-800/50 transition-colors">
                    <td className="px-6 py-4 font-mono text-xs text-primary font-bold">#{report.id}</td>
                    <td className="px-6 py-4">
                      <div className="text-sm font-semibold text-slate-800 dark:text-white">{report.title}</div>
                      <div className="text-xs text-slate-500 mt-0.5">{report.crime_type} • {new Date(report.created_at).toLocaleDateString()}</div>
                    </td>
                    <td className="px-6 py-4">
                      <span className={`inline-flex items-center gap-1.5 text-xs font-semibold px-2.5 py-1 rounded-full ${report.status === 'Resolved' ? 'text-emerald-600 bg-emerald-100' :
                          report.status === 'High Priority' ? 'text-red-600 bg-red-100' :
                            'text-blue-600 bg-blue-100'
                        }`}>
                        <span className={`w-1.5 h-1.5 rounded-full ${report.status === 'Resolved' ? 'bg-emerald-600' :
                            report.status === 'High Priority' ? 'bg-red-600 animate-ping' :
                              'bg-blue-600 animate-pulse'
                          }`}></span>
                        {report.status}
                      </span>
                    </td>
                  </tr>
                ))}
                {recentReports.length === 0 && (
                  <tr>
                    <td colSpan={3} className="px-6 py-8 text-center text-slate-500">No recent reports found.</td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>

        {/* Activity Log - Keeping Mock for now as requested only to remove "Map Region" */}
        <div className="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 p-6 shadow-sm h-fit">
          <h3 className="text-lg font-bold text-slate-800 dark:text-white mb-6">Recent Activity Log</h3>
          <div className="space-y-6">
            {MOCK_ACTIVITY.map((activity, idx) => (
              <div key={activity.id} className="flex gap-4">
                <div className="relative">
                  <div className={`w-2 h-2 rounded-full ring-4 z-10 relative ${activity.type === 'success' ? 'bg-emerald-500 ring-emerald-500/10' :
                      activity.type === 'danger' ? 'bg-red-500 ring-red-500/10' :
                        activity.type === 'info' ? 'bg-blue-500 ring-blue-500/10' :
                          'bg-slate-300 ring-slate-300/10'
                    }`}></div>
                  {idx !== MOCK_ACTIVITY.length - 1 && (
                    <div className="absolute top-2 left-1 w-px h-full bg-slate-200 dark:bg-slate-800"></div>
                  )}
                </div>
                <div>
                  <p className="text-sm font-medium text-slate-800 dark:text-white leading-none">{activity.title}</p>
                  <p className="text-xs text-slate-500 dark:text-slate-400 mt-1">{activity.description}</p>
                  <span className="text-[10px] text-slate-400 font-medium">{activity.time}</span>
                </div>
              </div>
            ))}
          </div>
          <button className="w-full mt-6 py-2 text-xs font-bold text-slate-600 dark:text-slate-400 border border-slate-200 dark:border-slate-800 rounded-lg hover:bg-slate-50 dark:hover:bg-slate-800 transition-colors">
            View All Logs
          </button>
        </div>
      </div>
    </div>
  );
};

export default Dashboard;
