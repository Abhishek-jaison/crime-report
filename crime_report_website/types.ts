
export type Status = 'Dispatched' | 'Pending' | 'High Priority' | 'Resolved' | 'Dismissed' | 'Investigating' | 'Closed (Dispatched)';
export type CrimeType = 'Theft' | 'Behavioral' | 'Critical' | 'Property' | 'Burglary' | 'Other' | 'Traffic' | 'SOS ALERT';

export interface Report {
  id: string;
  title: string;
  type: CrimeType;
  location: string;
  status: Status;
  timestamp: string;
  description?: string;
  latLng?: { lat: number; lng: number };
}

export interface User {
  id: string;
  name: string;
  email: string;
  verification: 'Verified' | 'Pending' | 'Unverified';
  complaints: number;
  joinDate: string;
  avatar: string;
  activeCount: number;
  sosCount: number;
}

export interface ActivityLog {
  id: string;
  title: string;
  description: string;
  time: string;
  type: 'success' | 'danger' | 'info' | 'neutral';
}
