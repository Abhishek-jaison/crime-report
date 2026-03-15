import React, { useState, useEffect } from 'react';
import { API_BASE_URL } from '../constants';

interface UserDetail {
  id: number;
  name: string | null;
  email: string;
  profile_pic: string | null;
  created_at: string;
  complaint_count: number;
}

interface Complaint {
  id: number;
  title: string;
  description: string;
  crime_type: string;
  user_email: string;
  status: string;
  created_at: string;
}

const formatDate = (iso: string) => {
  try {
    return new Date(iso).toLocaleDateString('en-IN', {
      day: '2-digit', month: 'short', year: 'numeric'
    });
  } catch {
    return iso;
  }
};

const formatRelative = (iso: string) => {
  try {
    const diff = Date.now() - new Date(iso).getTime();
    const mins = Math.floor(diff / 60000);
    if (mins < 60) return `${mins} min${mins !== 1 ? 's' : ''} ago`;
    const hrs = Math.floor(mins / 60);
    if (hrs < 24) return `${hrs} hr${hrs !== 1 ? 's' : ''} ago`;
    return formatDate(iso);
  } catch {
    return iso;
  }
};

const getInitials = (name: string | null, email: string) => {
  if (name) return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
  return email.slice(0, 2).toUpperCase();
};

const UserAvatar: React.FC<{ user: UserDetail; size?: string }> = ({ user, size = 'w-10 h-10' }) => {
  const [imgError, setImgError] = React.useState(false);
  if (user.profile_pic && !imgError) {
    return (
      <img
        src={user.profile_pic}
        alt={user.name ?? user.email}
        onError={() => setImgError(true)}
        className={`${size} rounded-full object-cover flex-shrink-0 border-2 border-white shadow`}
      />
    );
  }
  // No-pic silhouette (WhatsApp-style gray person)
  return (
    <div className={`${size} rounded-full bg-slate-200 dark:bg-slate-700 flex items-center justify-center flex-shrink-0 border-2 border-white shadow`}>
      <svg viewBox="0 0 24 24" className="w-3/5 h-3/5 text-slate-400 dark:text-slate-500" fill="currentColor">
        <path d="M12 12c2.7 0 4.8-2.1 4.8-4.8S14.7 2.4 12 2.4 7.2 4.5 7.2 7.2 9.3 12 12 12zm0 2.4c-3.2 0-9.6 1.6-9.6 4.8v2.4h19.2v-2.4c0-3.2-6.4-4.8-9.6-4.8z"/>
      </svg>
    </div>
  );
};

const UsersPage: React.FC = () => {
  const [users, setUsers] = useState<UserDetail[]>([]);
  const [selectedUser, setSelectedUser] = useState<UserDetail | null>(null);
  const [complaints, setComplaints] = useState<Complaint[]>([]);
  const [loadingUsers, setLoadingUsers] = useState(true);
  const [loadingComplaints, setLoadingComplaints] = useState(false);

  // Fetch all users on mount
  useEffect(() => {
    setLoadingUsers(true);
    fetch(`${API_BASE_URL}/auth/users/all`)
      .then(res => res.json())
      .then((data: UserDetail[]) => {
        setUsers(data);
        if (data.length > 0) setSelectedUser(data[0]);
      })
      .catch(err => console.error('Failed to fetch users:', err))
      .finally(() => setLoadingUsers(false));
  }, []);

  // Fetch complaints when selected user changes
  useEffect(() => {
    if (!selectedUser) return;
    setLoadingComplaints(true);
    fetch(`${API_BASE_URL}/complaints/my-complaints?user_email=${encodeURIComponent(selectedUser.email)}`)
      .then(res => res.json())
      .then((data: Complaint[]) => {
        const sorted = [...data].sort(
          (a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
        );
        setComplaints(sorted);
      })
      .catch(err => console.error('Failed to fetch complaints:', err))
      .finally(() => setLoadingComplaints(false));
  }, [selectedUser]);

  return (
    <div className="p-8 flex gap-8 h-[calc(100vh-80px)] overflow-hidden animate-in fade-in slide-in-from-bottom duration-500">
      {/* Left: Users Table */}
      <section className="flex-1 flex flex-col min-w-0">
        <div className="flex items-center justify-between mb-6">
          <div>
            <h1 className="text-2xl font-bold text-slate-900 dark:text-white">Registered Users</h1>
            <p className="text-sm text-slate-500 dark:text-slate-400">
              {loadingUsers ? 'Loading...' : `${users.length} registered citizen${users.length !== 1 ? 's' : ''}`}
            </p>
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
            {loadingUsers ? (
              <div className="flex items-center justify-center py-24 text-slate-400">
                <span className="material-icons animate-spin text-3xl mr-2">refresh</span>
                <span>Loading users…</span>
              </div>
            ) : users.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-24 text-slate-400">
                <span className="material-icons text-4xl mb-2">group_off</span>
                <p>No registered users found.</p>
              </div>
            ) : (
              <table className="w-full text-left border-collapse">
                <thead className="bg-slate-50 dark:bg-slate-800/50 sticky top-0 z-10 border-b border-slate-200 dark:border-slate-800">
                  <tr>
                    <th className="px-6 py-4 text-xs font-semibold text-slate-500 uppercase tracking-wider">User</th>
                    <th className="px-6 py-4 text-xs font-semibold text-slate-500 uppercase tracking-wider text-center">Complaints</th>
                    <th className="px-6 py-4 text-xs font-semibold text-slate-500 uppercase tracking-wider">Joined</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100 dark:divide-slate-800">
                  {users.map((user, idx) => (
                    <tr
                      key={user.id}
                      onClick={() => setSelectedUser(user)}
                      className={`hover:bg-slate-50 dark:hover:bg-slate-800/30 transition-colors cursor-pointer ${
                        selectedUser?.id === user.id ? 'bg-primary/5 border-l-4 border-l-primary' : ''
                      }`}
                    >
                      <td className="px-6 py-4">
                        <div className="flex items-center gap-3">
                          <UserAvatar user={user} size="w-10 h-10" />
                          <div>
                            <div className="text-sm font-semibold text-slate-900 dark:text-white">
                              {user.name || '(No Name)'}
                            </div>
                            <div className="text-xs text-slate-500">{user.email}</div>
                          </div>
                        </div>
                      </td>
                      <td className="px-6 py-4 text-center">
                        <span className="text-sm font-semibold text-slate-700 dark:text-slate-300">{user.complaint_count}</span>
                      </td>
                      <td className="px-6 py-4 text-sm text-slate-500">{formatDate(user.created_at)}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            )}
          </div>
          <div className="mt-auto p-4 border-t border-slate-200 dark:border-slate-800 bg-slate-50 dark:bg-slate-800/50 flex items-center justify-between">
            <span className="text-xs text-slate-500">
              {loadingUsers ? '—' : `Showing ${users.length} users`}
            </span>
          </div>
        </div>
      </section>

      {/* Right: User Detail Panel */}
      {selectedUser && (
        <section className="w-[450px] bg-white dark:bg-slate-900 rounded-xl border border-slate-200 dark:border-slate-800 flex flex-col shadow-sm animate-in slide-in-from-right duration-300">
          <div className="p-6 border-b border-slate-100 dark:border-slate-800 relative">
            <div className="flex flex-col items-center text-center">
                <div className="relative mb-4">
                  <UserAvatar user={selectedUser} size="w-24 h-24" />
                </div>
              <h2 className="text-xl font-bold text-slate-900 dark:text-white">
                {selectedUser.name || '(No Name)'}
              </h2>
              <p className="text-slate-500 text-sm">{selectedUser.email}</p>
              <p className="text-slate-400 text-xs mt-1">Citizen ID: #{selectedUser.id}</p>
              <div className="mt-4 flex gap-2">
                <button className="px-4 py-2 bg-primary text-white text-sm font-semibold rounded-lg hover:bg-primary/90 transition-colors">View Dossier</button>
                <button className="px-4 py-2 bg-primary/10 text-primary text-sm font-semibold rounded-lg hover:bg-primary/20 transition-colors">Contact</button>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-2 gap-px bg-slate-100 dark:bg-slate-800 border-b border-slate-100 dark:border-slate-800">
            <div className="bg-white dark:bg-slate-900 p-4 text-center">
              <div className="text-xs text-slate-500 uppercase font-semibold mb-1">Total Reports</div>
              <div className="text-xl font-bold text-slate-900 dark:text-white">{selectedUser.complaint_count}</div>
            </div>
            <div className="bg-white dark:bg-slate-900 p-4 text-center">
              <div className="text-xs text-slate-500 uppercase font-semibold mb-1">Joined</div>
              <div className="text-base font-bold text-slate-700 dark:text-slate-300">{formatDate(selectedUser.created_at)}</div>
            </div>
          </div>

          <div className="flex-1 overflow-y-auto custom-scrollbar p-6">
            <h3 className="text-sm font-bold text-slate-900 dark:text-white uppercase tracking-wider mb-4 flex items-center justify-between">
              Report History
              <span className="text-[10px] font-normal text-slate-400 bg-slate-100 dark:bg-slate-800 px-2 py-0.5 rounded">
                Latest {Math.min(complaints.length, 5)} of {complaints.length}
              </span>
            </h3>

            {loadingComplaints ? (
              <div className="flex items-center justify-center py-12 text-slate-400">
                <span className="material-icons animate-spin mr-2">refresh</span>
                Loading reports…
              </div>
            ) : complaints.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-12 text-slate-400">
                <span className="material-icons text-3xl mb-2">inbox</span>
                <p className="text-sm">No reports submitted yet.</p>
              </div>
            ) : (
              <div className="space-y-4">
                {complaints.slice(0, 5).map((rep) => (
                  <div key={rep.id} className="p-3 border border-slate-100 dark:border-slate-800 rounded-lg hover:border-primary/30 transition-all">
                    <div className="flex justify-between items-start mb-2">
                      <span className="text-xs font-semibold px-2 py-0.5 rounded bg-blue-100 text-blue-700">
                        {rep.crime_type}
                      </span>
                      <span className="text-[10px] text-slate-400">{formatRelative(rep.created_at)}</span>
                    </div>
                    <h4 className="text-sm font-semibold text-slate-800 dark:text-slate-200 mb-1">{rep.title}</h4>
                    <p className="text-xs text-slate-500 line-clamp-2">{rep.description}</p>
                    <div className="mt-2 flex items-center justify-end">
                      <span className={`flex items-center gap-1 text-[11px] font-medium ${
                        rep.status === 'Resolved' ? 'text-green-600' :
                        rep.status === 'Dispatched' ? 'text-blue-600' : 'text-amber-600'
                      }`}>
                        <span className={`w-1.5 h-1.5 rounded-full ${
                          rep.status === 'Resolved' ? 'bg-green-500' :
                          rep.status === 'Dispatched' ? 'bg-blue-500' : 'bg-amber-500'
                        }`}></span>
                        {rep.status}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </div>

          {complaints.length > 5 && (
            <div className="p-4 border-t border-slate-100 dark:border-slate-800">
              <button className="w-full py-2.5 flex items-center justify-center gap-2 text-primary font-semibold text-sm hover:bg-primary/5 rounded-lg transition-colors">
                See All {complaints.length} Reports <span className="material-icons text-sm">arrow_forward</span>
              </button>
            </div>
          )}
        </section>
      )}
    </div>
  );
};

export default UsersPage;
