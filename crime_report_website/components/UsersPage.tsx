
import React, { useState } from 'react';
import { MOCK_USERS, MOCK_REPORTS } from '../constants';
import { User } from '../types';

const UsersPage: React.FC = () => {
  const [selectedUser, setSelectedUser] = useState<User | null>(MOCK_USERS[0]);

  return (
    <div className="p-8 flex gap-8 h-[calc(100vh-80px)] overflow-hidden animate-in fade-in slide-in-from-bottom duration-500">
      <section className="flex-1 flex flex-col min-w-0">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-2xl font-bold text-slate-900 dark:text-white">Registered Users</h1>
            <p className="text-sm text-slate-500 dark:text-slate-400">Monitor and manage access for 2,408 registered citizens</p>
          </div>
          <div className="flex gap-2">
            <button className="flex items-center gap-2 px-4 py-2 border border-slate-200 dark:border-slate-700 rounded-lg text-sm font-medium hover:bg-slate-50 dark:hover:bg-slate-800">
              <span className="material-icons text-sm">filter_list</span> Filter
            </button>
            <button className="flex items-center gap-2 px-4 py-2 border border-slate-200 dark:border-slate-700 rounded-lg text-sm font-medium hover:bg-slate-50 dark:hover:bg-slate-800">
              <span className="material-icons text-sm">file_download</span> Export
            </button>
          </div>
        </div>

        <div className="bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 overflow-hidden flex-1 flex flex-col shadow-sm">
          <div className="overflow-y-auto custom-scrollbar">
            <table className="w-full text-left border-collapse">
              <thead className="bg-slate-50 dark:bg-slate-800/50 sticky top-0 z-10 border-b border-slate-200 dark:border-slate-800">
                <tr>
                  <th className="px-6 py-4 text-xs font-semibold text-slate-500 uppercase tracking-wider">User</th>
                  <th className="px-6 py-4 text-xs font-semibold text-slate-500 uppercase tracking-wider text-center">Verification</th>
                  <th className="px-6 py-4 text-xs font-semibold text-slate-500 uppercase tracking-wider text-center">Complaints</th>
                  <th className="px-6 py-4 text-xs font-semibold text-slate-500 uppercase tracking-wider">Join Date</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                {MOCK_USERS.map((user) => (
                  <tr 
                    key={user.id} 
                    onClick={() => setSelectedUser(user)}
                    className={`hover:bg-slate-50 dark:hover:bg-slate-800/30 transition-colors cursor-pointer ${
                      selectedUser?.id === user.id ? 'bg-primary/5 border-l-4 border-l-primary' : ''
                    }`}
                  >
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        <div className="h-10 w-10 rounded-lg bg-slate-200 dark:bg-slate-700 flex-shrink-0 flex items-center justify-center font-bold text-slate-500 overflow-hidden">
                          <img className="h-full w-full object-cover" src={user.avatar} alt={user.name} />
                        </div>
                        <div>
                          <div className="text-sm font-semibold text-slate-900 dark:text-white">{user.name}</div>
                          <div className="text-xs text-slate-500">{user.email}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                        user.verification === 'Verified' ? 'bg-green-100 text-green-700' :
                        user.verification === 'Pending' ? 'bg-amber-100 text-amber-700' :
                        'bg-red-100 text-red-700'
                      }`}>
                        {user.verification}
                      </span>
                    </td>
                    <td className="px-6 py-4 text-center">
                      <span className="text-sm font-semibold text-slate-700 dark:text-slate-300">{user.complaints}</span>
                    </td>
                    <td className="px-6 py-4 text-sm text-slate-500">{user.joinDate}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
          <div className="mt-auto p-4 border-t border-slate-200 dark:border-slate-800 bg-slate-50 dark:bg-slate-800/50 flex items-center justify-between">
            <span className="text-xs text-slate-500">Showing {MOCK_USERS.length} users</span>
            <div className="flex gap-2">
              <button className="p-2 border border-slate-200 dark:border-slate-700 rounded bg-white dark:bg-slate-900"><span className="material-icons text-xs leading-none">chevron_left</span></button>
              <button className="p-2 border border-slate-200 dark:border-slate-700 rounded bg-white dark:bg-slate-900"><span className="material-icons text-xs leading-none">chevron_right</span></button>
            </div>
          </div>
        </div>
      </section>

      {selectedUser && (
        <section className="w-[450px] bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 flex flex-col shadow-sm animate-in slide-in-from-right duration-300">
          <div className="p-6 border-b border-slate-100 dark:border-slate-800 relative">
            <button className="absolute right-4 top-4 text-slate-400 hover:text-slate-600">
              <span className="material-icons text-xl">more_vert</span>
            </button>
            <div className="flex flex-col items-center text-center">
              <div className="relative mb-4">
                <img className="w-24 h-24 rounded-2xl object-cover ring-4 ring-primary/10" src={selectedUser.avatar} alt={selectedUser.name} />
                <div className="absolute -bottom-2 -right-2 bg-green-500 border-4 border-white dark:border-slate-900 w-8 h-8 rounded-full flex items-center justify-center">
                  <span className="material-icons text-white text-base">verified</span>
                </div>
              </div>
              <h2 className="text-xl font-bold text-slate-900 dark:text-white">{selectedUser.name}</h2>
              <p className="text-slate-500 text-sm">Citizen ID: {selectedUser.id}</p>
              <div className="mt-4 flex gap-2">
                <button className="px-4 py-2 bg-primary text-white text-sm font-semibold rounded-lg hover:bg-primary/90 transition-colors">View Dossier</button>
                <button className="px-4 py-2 bg-primary/10 text-primary text-sm font-semibold rounded-lg hover:bg-primary/20 transition-colors">Contact</button>
              </div>
            </div>
          </div>
          <div className="grid grid-cols-3 gap-px bg-slate-100 dark:bg-slate-800 border-b border-slate-100 dark:border-slate-800">
            <div className="bg-white dark:bg-slate-900 p-4 text-center">
              <div className="text-xs text-slate-500 uppercase font-semibold mb-1">Total</div>
              <div className="text-xl font-bold text-slate-900 dark:text-white">{selectedUser.complaints}</div>
            </div>
            <div className="bg-white dark:bg-slate-900 p-4 text-center">
              <div className="text-xs text-slate-500 uppercase font-semibold mb-1">Active</div>
              <div className="text-xl font-bold text-primary">{selectedUser.activeCount}</div>
            </div>
            <div className="bg-white dark:bg-slate-900 p-4 text-center">
              <div className="text-xs text-slate-500 uppercase font-semibold mb-1">SOS</div>
              <div className="text-xl font-bold text-red-500">{selectedUser.sosCount}</div>
            </div>
          </div>
          <div className="flex-1 overflow-y-auto custom-scrollbar p-6">
            <h3 className="text-sm font-bold text-slate-900 dark:text-white uppercase tracking-wider mb-4 flex items-center justify-between">
              Report History
              <span className="text-[10px] font-normal text-slate-400 bg-slate-100 dark:bg-slate-800 px-2 py-0.5 rounded">Latest 5</span>
            </h3>
            <div className="space-y-4">
              {MOCK_REPORTS.slice(0, 3).map((rep) => (
                <div key={rep.id} className="p-3 border border-slate-100 dark:border-slate-800 rounded-lg hover:border-primary/30 transition-all group">
                  <div className="flex justify-between items-start mb-2">
                    <span className="text-xs font-semibold px-2 py-0.5 rounded bg-blue-100 text-blue-700">{rep.type}</span>
                    <span className="text-[10px] text-slate-400">{rep.timestamp}</span>
                  </div>
                  <h4 className="text-sm font-semibold text-slate-800 dark:text-slate-200 mb-1">{rep.title}</h4>
                  <div className="flex items-center justify-between">
                    <span className="flex items-center gap-1 text-[11px] text-slate-500">
                      <span className="material-icons text-xs">location_on</span> {rep.location}
                    </span>
                    <span className="flex items-center gap-1 text-[11px] font-medium text-amber-600">
                      <span className="w-1.5 h-1.5 rounded-full bg-amber-500"></span> {rep.status}
                    </span>
                  </div>
                </div>
              ))}
            </div>
          </div>
          <div className="p-4 border-t border-slate-100 dark:border-slate-800">
            <button className="w-full py-2.5 flex items-center justify-center gap-2 text-primary font-semibold text-sm hover:bg-primary/5 rounded-lg transition-colors">
              See All Reports <span className="material-icons text-sm">arrow_forward</span>
            </button>
          </div>
        </section>
      )}
    </div>
  );
};

export default UsersPage;
