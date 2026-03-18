import React, { useState, useEffect } from 'react';
import { API_BASE_URL } from '../constants';
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';

interface Complaint {
  id: number;
  title: string;
  description: string;
  crime_type: string;
  user_email: string;
  image_path: string | null;
  video_path: string | null;
  audio_path: string | null;
  lat: string | null;
  long: string | null;
  suspect_details: string | null;
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
    if (mins < 60) return `${mins} min${mins !== 1 ? 's' : ''} ago`;
    const hrs = Math.floor(mins / 60);
    if (hrs < 24) return `${hrs} hr${hrs !== 1 ? 's' : ''} ago`;
    return formatDate(iso);
  } catch { return iso; }
};

const statusColor = (s: string) => {
  if (s === 'Resolved')   return 'text-emerald-500';
  if (s === 'Dispatched') return 'text-blue-500';
  if (s === 'Terminated') return 'text-red-500';
  return 'text-amber-500';
};

const statusDot = (s: string) => {
  if (s === 'Resolved')   return 'bg-emerald-500';
  if (s === 'Dispatched') return 'bg-blue-500 animate-pulse';
  if (s === 'Terminated') return 'bg-red-500';
  return 'bg-amber-500 animate-pulse';
};

const statusBadge = (s: string) => {
  if (s === 'Resolved')   return 'bg-emerald-50 border-emerald-200 text-emerald-700 dark:bg-emerald-900/10 dark:border-emerald-900/30 dark:text-emerald-400';
  if (s === 'Dispatched') return 'bg-blue-50 border-blue-200 text-blue-700 dark:bg-blue-900/10 dark:border-blue-900/30 dark:text-blue-400';
  if (s === 'Terminated') return 'bg-red-50 border-red-200 text-red-700 dark:bg-red-900/10 dark:border-red-900/30 dark:text-red-400';
  return 'bg-amber-50 border-amber-200 text-amber-700 dark:bg-amber-900/10 dark:border-amber-900/30 dark:text-amber-400';
};

const ALL_TYPES = ['All Types', 'Theft', 'Burglary', 'Assault', 'Vandalism', 'Fraud', 'Other'];
const ALL_STATUSES = ['Any Status', 'Pending', 'Dispatched', 'Resolved', 'Terminated'];

const ReportsPage: React.FC = () => {
  const [reports, setReports] = useState<Complaint[]>([]);
  const [filtered, setFiltered] = useState<Complaint[]>([]);
  const [userPhoneMap, setUserPhoneMap] = useState<Record<string, string>>({});
  const [selectedReport, setSelectedReport] = useState<Complaint | null>(null);
  const [loading, setLoading] = useState(true);
  const [updating, setUpdating] = useState(false);
  const [generatingFIR, setGeneratingFIR] = useState(false);
  const [typeFilter, setTypeFilter] = useState('All Types');
  const [statusFilter, setStatusFilter] = useState('Any Status');

  const fetchAll = () => {
    setLoading(true);
    
    // Fetch users to populate the phone numbers map
    fetch(`${API_BASE_URL}/auth/users/all`)
      .then(res => res.json())
      .then((users: any[]) => {
        const map: Record<string, string> = {};
        users.forEach(u => {
          if (u.phone_number) map[u.email] = u.phone_number;
        });
        setUserPhoneMap(map);
      })
      .catch(err => console.error('Failed to fetch user directory for phone numbers:', err));

    fetch(`${API_BASE_URL}/complaints/all`)
      .then(res => res.json())
      .then((data: Complaint[]) => {
        setReports(data);
        // Refresh selected report data if it exists
        setSelectedReport(prev => prev ? (data.find(r => r.id === prev.id) ?? null) : (data[0] ?? null));
      })
      .catch(err => console.error('Failed to fetch reports:', err))
      .finally(() => setLoading(false));
  };

  useEffect(() => { fetchAll(); }, []);

  useEffect(() => {
    let result = [...reports];
    if (typeFilter !== 'All Types') result = result.filter(r => r.crime_type.toLowerCase() === typeFilter.toLowerCase());
    if (statusFilter !== 'Any Status') result = result.filter(r => r.status === statusFilter);
    setFiltered(result);
  }, [typeFilter, statusFilter, reports]);

  const updateStatus = async (newStatus: string) => {
    if (!selectedReport || updating) return;
    setUpdating(true);
    try {
      const res = await fetch(`${API_BASE_URL}/complaints/${selectedReport.id}/status`, {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: newStatus }),
      });
      if (!res.ok) throw new Error('Failed to update');
      const updated: Complaint = await res.json();
      // Update in-place across both lists
      setReports(prev => prev.map(r => r.id === updated.id ? updated : r));
      setSelectedReport(updated);
    } catch (e) {
      console.error('Status update failed:', e);
    } finally {
      setUpdating(false);
    }
  };

  const generateFIR = async (report: Complaint) => {
    setGeneratingFIR(true);
    try {
      let addressString = "Location coordinates not provided.";
      if (report.lat && report.long) {
        try {
          // Reverse geocoding using Nominatim
          const res = await fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${report.lat}&lon=${report.long}`);
          if (res.ok) {
            const data = await res.json();
            if (data.display_name) {
              addressString = data.display_name;
            } else {
              addressString = `Lat: ${report.lat}, Long: ${report.long}`;
            }
          } else {
            addressString = `Lat: ${report.lat}, Long: ${report.long}`;
          }
        } catch (e) {
          console.error("Geocoding failed", e);
          addressString = `Lat: ${report.lat}, Long: ${report.long}`;
        }
      }

      const phoneNumber = userPhoneMap[report.user_email] || "Not provided";
      const doc = new jsPDF();

      // Header
      doc.setFontSize(22);
      doc.setFont("helvetica", "bold");
      doc.text("FIRST INFORMATION REPORT (FIR)", 105, 20, { align: "center" });
      
      doc.setFontSize(10);
      doc.setFont("helvetica", "normal");
      doc.text(`Generated on: ${new Date().toLocaleString()}`, 105, 28, { align: "center" });
      doc.line(14, 32, 196, 32);

      // Report Details Table
      autoTable(doc, {
        startY: 40,
        head: [['Field', 'Details']],
        body: [
          ['Complaint ID', `#${report.id}`],
          ['Crime Type', report.crime_type],
          ['Date of Report', formatDate(report.created_at)],
          ['Incident Location', addressString],
        ],
        theme: 'grid',
        headStyles: { fillColor: [30, 64, 175] },
        styles: { fontSize: 10, cellPadding: 4 },
        columnStyles: { 0: { fontStyle: 'bold', cellWidth: 50 }, 1: { cellWidth: 'auto' } }
      });

      // Complainant Details Table
      autoTable(doc, {
        startY: (doc as any).lastAutoTable.finalY + 10,
        head: [['Complainant Information', '']],
        body: [
          ['Email', report.user_email],
          ['Phone Number', phoneNumber],
        ],
        theme: 'grid',
        headStyles: { fillColor: [30, 64, 175] },
        styles: { fontSize: 10, cellPadding: 4 },
        columnStyles: { 0: { fontStyle: 'bold', cellWidth: 50 }, 1: { cellWidth: 'auto' } }
      });

      // Suspect Details Table
      autoTable(doc, {
        startY: (doc as any).lastAutoTable.finalY + 10,
        head: [['Suspect Details', '']],
        body: [
          ['Information', report.suspect_details || 'Not provided by complainant'],
        ],
        theme: 'grid',
        headStyles: { fillColor: [220, 38, 38] }, // Red header for suspect
        styles: { fontSize: 10, cellPadding: 4 },
        columnStyles: { 0: { fontStyle: 'bold', cellWidth: 50 }, 1: { cellWidth: 'auto' } }
      });

      // Description
      const finalY = (doc as any).lastAutoTable.finalY + 15;
      doc.setFontSize(12);
      doc.setFont("helvetica", "bold");
      doc.text("Incident Description:", 14, finalY);
      
      doc.setFontSize(10);
      doc.setFont("helvetica", "normal");
      const splitDescription = doc.splitTextToSize(report.description, 180);
      doc.text(splitDescription, 14, finalY + 8);

      // Save
      doc.save(`FIR_Report_${report.id}.pdf`);
      
    } catch (error) {
      console.error("Failed to generate FIR:", error);
      alert("Failed to generate FIR. Please try again.");
    } finally {
      setGeneratingFIR(false);
    }
  };

  return (
    <div className="flex flex-col flex-1 h-[calc(100vh-80px)] overflow-hidden animate-in slide-in-from-right duration-500">
      {/* Filter Bar */}
      <div className="p-8 pb-4">
        <div className="flex flex-wrap items-center gap-4">
          <div className="flex-1 flex items-center gap-4">
            <select
              value={typeFilter}
              onChange={e => setTypeFilter(e.target.value)}
              className="form-select text-sm border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900 rounded-lg px-3 py-2 focus:outline-none"
            >
              {ALL_TYPES.map(t => <option key={t}>{t}</option>)}
            </select>
            <select
              value={statusFilter}
              onChange={e => setStatusFilter(e.target.value)}
              className="form-select text-sm border border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900 rounded-lg px-3 py-2 focus:outline-none"
            >
              {ALL_STATUSES.map(s => <option key={s}>{s}</option>)}
            </select>
          </div>
          <button
            onClick={() => { setTypeFilter('All Types'); setStatusFilter('Any Status'); }}
            className="bg-primary hover:bg-primary/90 text-white px-4 py-2 rounded-lg flex items-center gap-2 text-sm font-semibold transition-all"
          >
            <span className="material-icons text-base">filter_list</span>
            Clear Filters
          </button>
        </div>
      </div>

      <div className="flex-1 flex px-8 pb-8 gap-6 overflow-hidden">
        {/* Reports Table */}
        <div className="flex-1 bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 overflow-hidden flex flex-col shadow-sm">
          <div className="overflow-x-auto overflow-y-auto custom-scrollbar flex-1">
            {loading ? (
              <div className="flex items-center justify-center py-32 text-slate-400">
                <span className="material-icons animate-spin text-3xl mr-2">refresh</span>
                <span>Loading reports…</span>
              </div>
            ) : filtered.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-32 text-slate-400">
                <span className="material-icons text-5xl mb-3">inbox</span>
                <p className="text-base">No reports found.</p>
                <p className="text-sm mt-1">Try adjusting your filters.</p>
              </div>
            ) : (
              <table className="w-full text-left">
                <thead className="bg-slate-50 dark:bg-slate-800 border-b border-slate-200 dark:border-slate-800 sticky top-0 z-10">
                  <tr>
                    <th className="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Complaint Title</th>
                    <th className="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Type</th>
                    <th className="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Submitted By</th>
                    <th className="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Status</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                  {filtered.map((report) => (
                    <tr
                      key={report.id}
                      onClick={() => setSelectedReport(report)}
                      className={`hover:bg-primary/5 cursor-pointer transition-colors ${
                        selectedReport?.id === report.id ? 'bg-primary/5 border-l-4 border-l-primary' : ''
                      }`}
                    >
                      <td className="px-6 py-4">
                        <div className="font-semibold text-slate-800 dark:text-white">{report.title}</div>
                        <div className="text-xs text-slate-500">{formatRelative(report.created_at)}</div>
                      </td>
                      <td className="px-6 py-4">
                        <span className="px-3 py-1 bg-blue-100 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 text-xs font-bold rounded-full">
                          {report.crime_type}
                        </span>
                      </td>
                      <td className="px-6 py-4 text-sm text-slate-600 dark:text-slate-400">{report.user_email}</td>
                      <td className="px-6 py-4">
                        <span className={`flex items-center gap-1.5 text-sm font-semibold ${statusColor(report.status)}`}>
                          <span className={`w-2 h-2 rounded-full ${statusDot(report.status)}`}></span>
                          {report.status}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
          <div className="mt-auto p-4 border-t border-slate-200 dark:border-slate-800 flex items-center justify-between">
            <p className="text-xs text-slate-500 italic">
              {loading ? '—' : `Showing ${filtered.length} of ${reports.length} reports`}
            </p>
          </div>
        </div>

        {/* Detail Side Panel */}
        {selectedReport && (
          <div className="w-1/3 min-w-[390px] bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 shadow-xl flex flex-col overflow-hidden animate-in slide-in-from-right duration-300">
            <div className="p-6 border-b border-slate-200 dark:border-slate-800 bg-slate-50 dark:bg-slate-800/50">
              <div className="flex justify-between items-start mb-2">
                <span className="text-[10px] font-bold tracking-widest text-slate-400 uppercase">Report Details</span>
                <button onClick={() => setSelectedReport(null)} className="text-slate-400 hover:text-slate-600">
                  <span className="material-icons">close</span>
                </button>
              </div>
              <h2 className="text-lg font-bold text-slate-800 dark:text-white leading-tight">{selectedReport.title}</h2>
              <p className="text-xs text-primary font-bold mt-1 uppercase tracking-tight">Case ID: #{selectedReport.id}</p>
            </div>

            <div className="flex-1 overflow-y-auto custom-scrollbar p-6 space-y-6">
              {/* Status + Type */}
              <div className="flex gap-2">
                <div className={`flex-1 p-3 border rounded-lg ${statusBadge(selectedReport.status)}`}>
                  <p className="text-[10px] font-bold uppercase tracking-wide opacity-70">Current Status</p>
                  <p className="text-sm font-bold mt-0.5 flex items-center gap-1.5">
                    <span className={`w-2 h-2 rounded-full ${statusDot(selectedReport.status)}`}></span>
                    {selectedReport.status}
                  </p>
                </div>
                <div className="flex-1 p-3 bg-blue-50 dark:bg-blue-900/10 border border-blue-200 dark:border-blue-900/30 rounded-lg">
                  <p className="text-[10px] font-bold text-blue-600 dark:text-blue-400 uppercase tracking-wide">Crime Type</p>
                  <p className="text-sm font-semibold text-blue-700 dark:text-blue-300 mt-0.5">{selectedReport.crime_type}</p>
                </div>
              </div>

              {/* Submitted by + Date */}
              <div className="space-y-3">
                <div className="flex items-center gap-3 p-3 bg-slate-50 dark:bg-slate-800/50 rounded-lg border border-slate-100 dark:border-slate-800">
                  <span className="material-icons text-slate-400 text-base">person</span>
                  <div>
                    <p className="text-[10px] font-bold text-slate-400 uppercase">Submitted By</p>
                    <p className="text-sm font-semibold text-slate-700 dark:text-slate-300">{selectedReport.user_email}</p>
                    {userPhoneMap[selectedReport.user_email] && (
                      <p className="text-xs font-mono text-slate-500 mt-0.5">{userPhoneMap[selectedReport.user_email]}</p>
                    )}
                  </div>
                </div>
                <div className="flex items-center gap-3 p-3 bg-slate-50 dark:bg-slate-800/50 rounded-lg border border-slate-100 dark:border-slate-800">
                  <span className="material-icons text-slate-400 text-base">schedule</span>
                  <div>
                    <p className="text-[10px] font-bold text-slate-400 uppercase">Submitted At</p>
                    <p className="text-sm font-semibold text-slate-700 dark:text-slate-300">{formatDate(selectedReport.created_at)}</p>
                  </div>
                </div>
              </div>

              {/* Evidence */}
              {(selectedReport.image_path || selectedReport.video_path || selectedReport.audio_path) ? (
                <div>
                  <h3 className="text-sm font-bold text-slate-700 dark:text-slate-300 mb-3 flex items-center gap-2">
                    <span className="material-icons text-base">photo_library</span>
                    Evidence
                  </h3>
                  <div className="space-y-3">
                    {selectedReport.image_path && (
                      <div className="relative group cursor-pointer overflow-hidden rounded-xl border border-slate-200 dark:border-slate-800">
                        <img
                          className="w-full h-40 object-cover group-hover:scale-105 transition-transform duration-500 brightness-90"
                          src={selectedReport.image_path}
                          alt="Evidence photo"
                          onError={(e) => { (e.target as HTMLImageElement).style.display = 'none'; }}
                        />
                        <div className="absolute inset-0 bg-black/40 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                          <span className="material-icons text-white">zoom_in</span>
                        </div>
                      </div>
                    )}
                    {selectedReport.video_path && (
                      <a href={selectedReport.video_path} target="_blank" rel="noopener noreferrer"
                        className="relative flex items-center justify-center h-28 bg-slate-900 rounded-xl border border-slate-800 overflow-hidden cursor-pointer group mb-3">
                        <span className="material-icons text-white text-5xl group-hover:scale-110 transition-transform">play_circle</span>
                        <p className="text-xs text-slate-400 absolute bottom-3 left-3">Click to open video</p>
                      </a>
                    )}
                    {selectedReport.audio_path && (
                      <div className="w-full bg-slate-50 dark:bg-slate-800/50 p-4 rounded-xl border border-slate-200 dark:border-slate-700">
                        <p className="text-xs font-bold text-slate-500 mb-2 uppercase tracking-tight flex items-center gap-1.5">
                          <span className="material-icons text-sm">mic</span> Voice Note Description
                        </p>
                        <audio controls className="w-full h-10 outline-none" src={selectedReport.audio_path}>
                          Your browser does not support the audio element.
                        </audio>
                      </div>
                    )}
                  </div>
                </div>
              ) : (
                <div className="flex flex-col items-center justify-center py-5 text-slate-300 dark:text-slate-600 border border-dashed border-slate-200 dark:border-slate-700 rounded-xl">
                  <span className="material-icons text-3xl mb-1">hide_image</span>
                  <p className="text-xs">No evidence attached</p>
                </div>
              )}

              {/* Description */}
              <div>
                <h3 className="text-sm font-bold text-slate-700 dark:text-slate-300 mb-2">Description</h3>
                <p className="text-sm text-slate-600 dark:text-slate-400 leading-relaxed bg-slate-50 dark:bg-slate-800/50 p-4 rounded-lg border border-slate-100 dark:border-slate-800">
                  {selectedReport.description}
                </p>
              </div>
            </div>

            {/* Action Buttons */}
            <div className="p-5 border-t border-slate-200 dark:border-slate-800 bg-slate-50 dark:bg-slate-800/20 space-y-3">
              <p className="text-[10px] font-bold text-slate-400 uppercase tracking-widest mb-2">Update Status</p>

              {/* Dispatch row */}
              <div className="grid grid-cols-2 gap-3">
                <button
                  disabled={updating || selectedReport.status === 'Dispatched'}
                  onClick={() => updateStatus('Dispatched')}
                  className="px-3 py-2.5 bg-blue-600 disabled:opacity-40 disabled:cursor-not-allowed text-white text-sm font-bold rounded-lg hover:bg-blue-700 active:scale-95 transition-all flex items-center justify-center gap-2 shadow-md shadow-blue-500/20"
                >
                  <span className="material-icons text-base">local_police</span>
                  Dispatch Unit
                </button>

                <button
                  disabled={updating || selectedReport.status === 'Resolved'}
                  onClick={() => updateStatus('Resolved')}
                  className="px-3 py-2.5 bg-emerald-600 disabled:opacity-40 disabled:cursor-not-allowed text-white text-sm font-bold rounded-lg hover:bg-emerald-700 active:scale-95 transition-all flex items-center justify-center gap-2 shadow-md shadow-emerald-500/20"
                >
                  <span className="material-icons text-base">check_circle</span>
                  Mark Resolved
                </button>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <button
                  disabled={updating || selectedReport.status === 'Pending'}
                  onClick={() => updateStatus('Pending')}
                  className="px-3 py-2.5 bg-amber-500 disabled:opacity-40 disabled:cursor-not-allowed text-white text-sm font-bold rounded-lg hover:bg-amber-600 active:scale-95 transition-all flex items-center justify-center gap-2 shadow-md shadow-amber-400/20"
                >
                  <span className="material-icons text-base">hourglass_top</span>
                  Set Pending
                </button>

                <button
                  disabled={updating || selectedReport.status === 'Terminated'}
                  onClick={() => updateStatus('Terminated')}
                  className="px-3 py-2.5 bg-red-600 disabled:opacity-40 disabled:cursor-not-allowed text-white text-sm font-bold rounded-lg hover:bg-red-700 active:scale-95 transition-all flex items-center justify-center gap-2 shadow-md shadow-red-500/20"
                >
                  <span className="material-icons text-base">cancel</span>
                  Terminate
                </button>
              </div>

              {/* Download FIR Button */}
              <div className="grid grid-cols-1 mt-2">
                <button
                  disabled={generatingFIR}
                  onClick={() => generateFIR(selectedReport)}
                  className="w-full px-3 py-3 bg-slate-800 disabled:opacity-40 disabled:cursor-not-allowed text-white text-sm font-bold rounded-lg hover:bg-slate-900 active:scale-95 transition-all flex items-center justify-center gap-2 shadow-md shadow-slate-900/20"
                >
                  {generatingFIR ? (
                    <span className="material-icons text-base animate-spin">refresh</span>
                  ) : (
                    <span className="material-icons text-base">picture_as_pdf</span>
                  )}
                  {generatingFIR ? 'Generating FIR...' : 'Download Official FIR'}
                </button>
              </div>

              {updating && (
                <p className="text-center text-xs text-slate-400 animate-pulse flex items-center justify-center gap-1">
                  <span className="material-icons text-xs animate-spin">refresh</span>
                  Updating status…
                </p>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default ReportsPage;
