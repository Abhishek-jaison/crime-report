
import { Report, User, ActivityLog } from './types';

export const MOCK_REPORTS: Report[] = [
  {
    id: '#CR-92841',
    title: 'Attempted Robbery',
    type: 'Theft',
    location: 'Oakridge Business Park',
    status: 'Dispatched',
    timestamp: '12 mins ago',
    description: 'An unknown individual was spotted attempting to force entry into the rear service door of the business park center. Suspect wearing dark hoodie.'
  },
  {
    id: '#CR-92840',
    title: 'Public Nuisance',
    type: 'Behavioral',
    location: 'Central Metro Station',
    status: 'Pending',
    timestamp: '45 mins ago',
    description: 'Loud disturbance reported near Terminal B. Group of youths obstructing transit flow.'
  },
  {
    id: '#SOS-00421',
    title: 'Medical Emergency - SOS',
    type: 'Critical',
    location: 'Harbor View Apartments',
    status: 'High Priority',
    timestamp: '3 mins ago',
    description: 'Panic button triggered. Elder citizen reported chest pains and difficulty breathing.'
  },
  {
    id: '#CR-92838',
    title: 'Vandalism Incident',
    type: 'Property',
    location: 'Sunset Blvd Park',
    status: 'Resolved',
    timestamp: '1 hour ago',
    description: 'Graffiti discovered on the main monument. Clean-up crew dispatched and area cleared.'
  },
  {
    id: '#CR-2023-402',
    title: 'Attempted Burglary at Main St.',
    type: 'Burglary',
    location: 'Downtown, Sector 4',
    status: 'Pending',
    timestamp: 'Oct 24, 2023 10:45 AM',
    description: 'Suspect spotted trying to bypass lock on retail storefront. Fled when approached by witness.'
  }
];

export const MOCK_USERS: User[] = [
  {
    id: '#99283-4',
    name: 'Marcus Richardson',
    email: 'marcus.r@example.gov',
    verification: 'Verified',
    complaints: 12,
    joinDate: 'Jan 12, 2023',
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBT168Ug7A3-0s07KPsGio5Aoey-DydrVcz4oVOCJdpNcAYFaJqmCwDSw5GRrD0bLkf2vALy4ejFB9GhcxwPmqYdv1y5dl_kY2dxOPnTviNml5OBfZIf1aaOpn7KYCL0aSCJkwNeyl9Fnyg42R_Tc9EF94Gg5PZWHJskZr8M-O6u284WQWiWbloddBZuwiEpGg81GBrlirCEu3HbjjRBwy8dAOJ3RsKsryTPaE74ImqCd2YLUgGJW7KclYhGHYvQjMeqq85UqjwLZEX',
    activeCount: 2,
    sosCount: 1
  },
  {
    id: '#99283-5',
    name: 'Sarah Jenkins',
    email: 's.jenkins@provider.com',
    verification: 'Pending',
    complaints: 3,
    joinDate: 'Mar 05, 2023',
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuA_fBORMIX-14uenl7lMauyCTSLx99qZIF3Cavxe5QqcCchYPsIzq0xbNI93EKB5gbtI5AY5zKXNc8ymMgXiclwTCRSfoTpaoTGRYuXmZrVFnPWa3s0JGha-pUireBvnkVzO7Zxm04Uhtbmpmym7uw9NFkm-3LzrtCiezQjGLFb0vTH2ZgbtmOunP0OaKm6ktSCWoAsRis4Mps_Gc3QVy-GeJtoTqmJyBTY_4TTFMGWLWZ5ADI8pJ6Xan5IZYiJcI0bMp7tp6OxVSL4',
    activeCount: 0,
    sosCount: 0
  },
  {
    id: '#99283-6',
    name: 'David Chen',
    email: 'dchen_92@mail.net',
    verification: 'Verified',
    complaints: 7,
    joinDate: 'May 21, 2023',
    avatar: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBNF_5xO6uKZCn8R6Hqbd_EpxUB7fECVvsoNjFVvZG9sv21SDqzekPW6MrLqsSGB7nz0mWJBh1Cofb0_GLwKk8aFlkpvfBxlTuBbj-v64TosRk04yfJ3ict4KfegSi7NiZJ7fgEg1nTzjPnhaniYW5uEiR4MUa9f7gMQJa1lrULHEdBFQp-xZozDlGHfo9upPZWrkqFV-nt1Vt1F1mOxEfjQP3VHydpoOSPQCXcQR9wT2TyN4qLbhl7YnWyCK9NaQHHli0JBqytJ9Jn',
    activeCount: 1,
    sosCount: 0
  }
];

export const MOCK_ACTIVITY: ActivityLog[] = [
  { id: '1', title: 'Dispatcher Assigned', description: 'Unit 7 assigned to #CR-92841', time: '14:22 PM', type: 'success' },
  { id: '2', title: 'New SOS Alert', description: 'Signal received from Harbor View', time: '14:19 PM', type: 'danger' },
  { id: '3', title: 'Status Update', description: '#CR-92838 marked as Resolved', time: '13:58 PM', type: 'info' },
  { id: '4', title: 'User Login', description: 'Admin Miller authenticated', time: '13:30 PM', type: 'neutral' }
];
