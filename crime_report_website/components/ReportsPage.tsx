
import React, { useState } from 'react';
import { MOCK_REPORTS } from '../constants';
import { Report } from '../types';

const ReportsPage: React.FC = () => {
  const [selectedReport, setSelectedReport] = useState<Report | null>(MOCK_REPORTS[0]);

  return (
    <div className="flex flex-col flex-1 h-[calc(100vh-80px)] overflow-hidden animate-in slide-in-from-right duration-500">
      <div className="p-8 pb-4">
        <div className="flex flex-wrap items-center gap-4">
          <div className="flex-1 flex items-center gap-4">
            <select className="form-select text-sm border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900 rounded-lg focus:ring-primary">
              <option>All Crime Types</option>
              <option>Theft</option>
              <option>Burglary</option>
              <option>Other</option>
            </select>
            <select className="form-select text-sm border-slate-200 dark:border-slate-700 bg-white dark:bg-slate-900 rounded-lg focus:ring-primary">
              <option>Any Status</option>
              <option>Pending</option>
              <option>Dispatched</option>
              <option>Resolved</option>
            </select>
            <div className="hidden sm:flex items-center bg-white dark:bg-slate-900 border border-slate-200 dark:border-slate-700 rounded-lg px-3 py-2 gap-2 text-sm">
              <span className="material-icons text-slate-400 text-base">calendar_today</span>
              <span className="text-slate-600 dark:text-slate-300">Oct 01 - Oct 31, 2023</span>
            </div>
          </div>
          <button className="bg-primary hover:bg-primary/90 text-white px-4 py-2 rounded-lg flex items-center gap-2 text-sm font-semibold transition-all">
            <span className="material-icons text-base">filter_list</span>
            Apply Filters
          </button>
        </div>
      </div>

      <div className="flex-1 flex px-8 pb-8 gap-6 overflow-hidden">
        {/* Table Container */}
        <div className="flex-1 bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 overflow-hidden flex flex-col shadow-sm">
          <div className="overflow-x-auto custom-scrollbar flex-1">
            <table className="w-full text-left">
              <thead className="bg-slate-50 dark:bg-slate-800 border-b border-slate-200 dark:border-slate-800">
                <tr>
                  <th className="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Complaint Title</th>
                  <th className="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Type</th>
                  <th className="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Location</th>
                  <th className="px-6 py-4 text-xs font-bold text-slate-500 dark:text-slate-400 uppercase tracking-wider">Status</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                {MOCK_REPORTS.map((report) => (
                  <tr 
                    key={report.id} 
                    onClick={() => setSelectedReport(report)}
                    className={`hover:bg-primary/5 cursor-pointer transition-colors ${
                      selectedReport?.id === report.id ? 'bg-primary/5 border-l-4 border-l-primary' : ''
                    }`}
                  >
                    <td className="px-6 py-4">
                      <div className="font-semibold text-slate-800 dark:text-white">{report.title}</div>
                      <div className="text-xs text-slate-500">ID: {report.id}</div>
                    </td>
                    <td className="px-6 py-4">
                      <span className="px-3 py-1 bg-blue-100 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 text-xs font-bold rounded-full">
                        {report.type}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-sm text-slate-600 dark:text-slate-400">
                      <div className="flex items-center gap-1">
                        <span className="material-icons text-xs text-slate-400">place</span>
                        {report.location}
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <span className={`flex items-center gap-1.5 text-sm font-semibold ${
                        report.status === 'Resolved' ? 'text-emerald-500' :
                        report.status === 'High Priority' ? 'text-red-500' :
                        'text-amber-500'
                      }`}>
                        <span className={`w-2 h-2 rounded-full ${
                          report.status === 'Resolved' ? 'bg-emerald-500' :
                          report.status === 'High Priority' ? 'bg-red-500 animate-ping' :
                          'bg-amber-500 animate-pulse'
                        }`}></span>
                        {report.status}
                      </span>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <div className="mt-auto p-4 border-t border-slate-200 dark:border-slate-800 flex items-center justify-between">
            <p className="text-xs text-slate-500 italic">Showing 1 to 10 of 245 reports</p>
            <div className="flex items-center gap-2">
              <button className="p-1 hover:bg-slate-100 dark:hover:bg-slate-800 rounded border border-slate-200 dark:border-slate-700">
                <span className="material-icons text-sm">chevron_left</span>
              </button>
              <span className="text-xs font-bold text-white px-3 py-1 bg-primary rounded shadow-sm shadow-primary/20">1</span>
              <button className="p-1 hover:bg-slate-100 dark:hover:bg-slate-800 rounded border border-slate-200 dark:border-slate-700">
                <span className="material-icons text-sm">chevron_right</span>
              </button>
            </div>
          </div>
        </div>

        {/* Detail Side Panel */}
        {selectedReport && (
          <div className="w-1/3 min-w-[380px] bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 shadow-xl flex flex-col overflow-hidden animate-in slide-in-from-right duration-300">
            <div className="p-6 border-b border-slate-200 dark:border-slate-800 bg-slate-50 dark:bg-slate-800/50">
              <div className="flex justify-between items-start mb-2">
                <span className="text-[10px] font-bold tracking-widest text-slate-400 uppercase">Report Details</span>
                <button onClick={() => setSelectedReport(null)} className="text-slate-400 hover:text-slate-600">
                  <span className="material-icons">close</span>
                </button>
              </div>
              <h2 className="text-lg font-bold text-slate-800 dark:text-white leading-tight">{selectedReport.title}</h2>
              <p className="text-xs text-primary font-bold mt-1 uppercase tracking-tight">Case ID: {selectedReport.id}</p>
            </div>
            
            <div className="flex-1 overflow-y-auto custom-scrollbar p-6 space-y-6">
              <div className="flex gap-2">
                <div className="flex-1 p-3 bg-amber-50 dark:bg-amber-900/10 border border-amber-200 dark:border-amber-900/30 rounded-lg">
                  <p className="text-[10px] font-bold text-amber-600 dark:text-amber-500 uppercase tracking-wide">Status</p>
                  <p className="text-sm font-semibold text-amber-700 dark:text-amber-400 mt-0.5">{selectedReport.status}</p>
                </div>
                <div className="flex-1 p-3 bg-red-50 dark:bg-red-900/10 border border-red-200 dark:border-red-900/30 rounded-lg">
                  <p className="text-[10px] font-bold text-red-600 dark:text-red-500 uppercase tracking-wide">Priority</p>
                  <p className="text-sm font-semibold text-red-700 dark:text-red-400 mt-0.5">High Priority</p>
                </div>
              </div>

              <div>
                <h3 className="text-sm font-bold text-slate-700 dark:text-slate-300 mb-3 flex items-center gap-2">
                  <span className="material-icons text-base">photo_library</span>
                  Evidence (1 Photo)
                </h3>
                <div className="relative group cursor-pointer overflow-hidden rounded-xl border border-slate-200 dark:border-slate-800">
                  <img 
                    className="w-full h-40 object-cover group-hover:scale-105 transition-transform duration-500 brightness-75" 
                    src="https://lh3.googleusercontent.com/aida-public/AB6AXuA3evO9hPoak31GsrIGN5jFjcdl9HBcKgNT3lZupR_oKJQ0wWxiw290d6IbD05ATj7xYu7aGjmFl5ro6h2lppgSwPM6tvWOOto2LYZW1OA9hB9sxpSMIBogJ1qoUOIi1E_4zzKlPqMlqAfWMSQ6yD-oGJUvhV6vqdR3WNKjSjdvjkgktMSJWf6P2CmpBQpG4UDc4zWoOr9CZVi1AMurwy_Y84QgI3WRdg35sq75N60WkcEwJUuftCzJ08loxREZum_yHP-vntBcWfm3"
                  />
                  <div className="absolute inset-0 bg-black/40 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity">
                    <span className="material-icons text-white">zoom_in</span>
                  </div>
                </div>
              </div>

              <div>
                <h3 className="text-sm font-bold text-slate-700 dark:text-slate-300 mb-2">Description</h3>
                <p className="text-sm text-slate-600 dark:text-slate-400 leading-relaxed bg-slate-50 dark:bg-slate-800/50 p-4 rounded-lg border border-slate-100 dark:border-slate-800">
                  {selectedReport.description}
                </p>
              </div>

              <div>
                <div className="flex justify-between items-center mb-2">
                  <h3 className="text-sm font-bold text-slate-700 dark:text-slate-300">Incident Location</h3>
                  <button className="text-xs text-primary font-bold hover:underline">Open Map</button>
                </div>
                <div className="h-32 rounded-xl bg-slate-200 dark:bg-slate-800 relative overflow-hidden">
                  <img 
                    className="w-full h-full object-cover opacity-60 filter grayscale" 
                    src="https://lh3.googleusercontent.com/aida-public/AB6AXuAdhXXg8Vrr9bxdiPLLqMdlhb-K9EGwy3i_ooOqTjV1WNsPSMRPpwdFSJtPDfoSM_OKEdxp1XvxbsJ0Nydg2mlEvj4j5S5eXw4sZauEMYu5KxAoEAHsO76ZGJWZKIvTeSIEM1yr2FtBzD2_ZFVELSlLMbQCGsnSCyxAOn6GFm9jUllh3lnFRIFTa-4ZagqTjxZ72RiJ5DSRj8oTz0273AOwmeHABTNh-j22pH2_7veNA0jbc-FmqJcvfW63DPH2yGcMZwG80fP09ifw"
                  />
                  <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
                    <span className="material-icons text-red-600 drop-shadow-md">location_on</span>
                  </div>
                </div>
              </div>
            </div>

            <div className="p-6 border-t border-slate-200 dark:border-slate-800 grid grid-cols-2 gap-4 bg-slate-50 dark:bg-slate-800/20">
              <button className="px-4 py-2.5 bg-slate-200 dark:bg-slate-700 text-slate-700 dark:text-slate-300 text-sm font-bold rounded-lg hover:bg-slate-300 transition-colors flex items-center justify-center gap-2">
                <span className="material-icons text-sm">forward</span>
                Escalate
              </button>
              <button className="px-4 py-2.5 bg-primary text-white text-sm font-bold rounded-lg hover:bg-primary/90 transition-colors shadow-lg shadow-primary/20 flex items-center justify-center gap-2">
                <span className="material-icons text-sm">check_circle</span>
                Reviewed
              </button>
            </div>
          </div>
        )}
      </div>
    </div>
  );
};

export default ReportsPage;
