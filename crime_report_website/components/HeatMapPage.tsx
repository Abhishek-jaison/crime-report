import React, { useEffect, useRef, useState } from 'react';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { API_BASE_URL } from '../constants';

// Fix Leaflet default marker icons broken by bundlers
import markerIcon2x from 'leaflet/dist/images/marker-icon-2x.png';
import markerIcon from 'leaflet/dist/images/marker-icon.png';
import markerShadow from 'leaflet/dist/images/marker-shadow.png';

delete (L.Icon.Default.prototype as any)._getIconUrl;
L.Icon.Default.mergeOptions({
  iconUrl: markerIcon,
  iconRetinaUrl: markerIcon2x,
  shadowUrl: markerShadow,
});

interface SOSAlert {
  id: number;
  user_email: string | null;
  lat: string;
  long: string;
  created_at: string;
}

interface Complaint {
  id: number;
  title: string;
  crime_type: string;
  status: string;
  user_email: string;
  created_at: string;
}

const formatRelative = (iso: string) => {
  try {
    const diff = Date.now() - new Date(iso).getTime();
    const mins = Math.floor(diff / 60000);
    if (mins < 60) return `${mins}m ago`;
    const hrs = Math.floor(mins / 60);
    if (hrs < 24) return `${hrs}h ago`;
    return new Date(iso).toLocaleDateString('en-IN', { day: '2-digit', month: 'short' });
  } catch { return iso; }
};

const HeatMapPage: React.FC = () => {
  const mapRef = useRef<HTMLDivElement>(null);
  const mapInstanceRef = useRef<L.Map | null>(null);
  const locationMarkerRef = useRef<L.LayerGroup | null>(null);
  const [sosAlerts, setSosAlerts] = useState<SOSAlert[]>([]);
  const [complaints, setComplaints] = useState<Complaint[]>([]);
  const [loading, setLoading] = useState(true);
  const [showSOS, setShowSOS] = useState(true);
  const [showComplaints, setShowComplaints] = useState(true);
  const [locating, setLocating] = useState(false);
  const [locationError, setLocationError] = useState<string | null>(null);

  const locateMe = () => {
    const map = mapInstanceRef.current;
    if (!map || !navigator.geolocation) {
      setLocationError('Geolocation not supported by your browser.');
      return;
    }
    setLocating(true);
    setLocationError(null);
    navigator.geolocation.getCurrentPosition(
      (pos) => {
        const { latitude: lat, longitude: lng, accuracy } = pos.coords;
        // Remove old location layer if exists
        if (locationMarkerRef.current) {
          locationMarkerRef.current.removeFrom(map);
        }
        const group = L.layerGroup();
        // Accuracy circle (light blue)
        L.circle([lat, lng], {
          radius: accuracy,
          color: '#2563eb',
          fillColor: '#3b82f6',
          fillOpacity: 0.12,
          weight: 1,
        }).addTo(group);
        // Blue dot — Google Maps style
        const blueDot = L.divIcon({
          className: '',
          html: `
            <div style="position:relative;display:flex;align-items:center;justify-content:center;">
              <div style="position:absolute;width:28px;height:28px;border-radius:50%;background:rgba(59,130,246,0.25);animation:ping 1.8s cubic-bezier(0,0,0.2,1) infinite;"></div>
              <div style="width:16px;height:16px;border-radius:50%;background:#2563eb;border:3px solid white;box-shadow:0 2px 8px rgba(37,99,235,0.6);z-index:1;"></div>
            </div>`,
          iconSize: [28, 28],
          iconAnchor: [14, 14],
        });
        L.marker([lat, lng], { icon: blueDot })
          .bindPopup(`<div style="font-family:sans-serif;"><b style="color:#2563eb;">📍 You are here</b><br/><span style="font-size:11px;color:#64748b;">${lat.toFixed(5)}, ${lng.toFixed(5)}</span><br/><span style="font-size:10px;color:#94a3b8;">Accuracy: ±${Math.round(accuracy)}m</span></div>`)
          .addTo(group)
          .openPopup();
        group.addTo(map);
        locationMarkerRef.current = group;
        map.flyTo([lat, lng], 15, { duration: 1.8 });
        setLocating(false);
      },
      (err) => {
        setLocating(false);
        if (err.code === 1) setLocationError('Location access denied. Please allow location in browser settings.');
        else setLocationError('Could not get your location. Try again.');
        setTimeout(() => setLocationError(null), 4000);
      },
      { enableHighAccuracy: true, timeout: 10000 }
    );
  };

  // Fetch data
  useEffect(() => {
    Promise.all([
      fetch(`${API_BASE_URL}/sos/all`).then(r => r.json()).catch(() => []),
      fetch(`${API_BASE_URL}/complaints/all`).then(r => r.json()).catch(() => []),
    ]).then(([sos, comps]) => {
      setSosAlerts(sos as SOSAlert[]);
      setComplaints(comps as Complaint[]);
      setLoading(false);
    });
  }, []);

  // Initialize map once
  useEffect(() => {
    if (!mapRef.current || mapInstanceRef.current) return;

    const map = L.map(mapRef.current, {
      center: [20.5937, 78.9629], // Center of India (default)
      zoom: 5,
      zoomControl: false,
    });

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
      maxZoom: 19,
    }).addTo(map);

    // Custom zoom control (bottom-right)
    L.control.zoom({ position: 'bottomright' }).addTo(map);

    mapInstanceRef.current = map;

    return () => {
      map.remove();
      mapInstanceRef.current = null;
    };
  }, []);

  // Add/refresh markers whenever data or toggle changes
  useEffect(() => {
    const map = mapInstanceRef.current;
    if (!map || loading) return;

    // Clear all existing layers except tile layers
    map.eachLayer(layer => {
      if (!(layer instanceof L.TileLayer)) map.removeLayer(layer);
    });

    const markersAdded: L.LatLng[] = [];

    // SOS Alert markers — RED pulsing
    if (showSOS) {
      sosAlerts.forEach(alert => {
        const lat = parseFloat(alert.lat);
        const lng = parseFloat(alert.long);
        if (isNaN(lat) || isNaN(lng)) return;

        const latlng = L.latLng(lat, lng);
        markersAdded.push(latlng);

        const icon = L.divIcon({
          className: '',
          html: `
            <div style="position:relative;display:flex;align-items:center;justify-content:center;">
              <div style="position:absolute;width:32px;height:32px;border-radius:50%;background:rgba(239,68,68,0.3);animation:ping 1.5s cubic-bezier(0,0,0.2,1) infinite;"></div>
              <div style="width:16px;height:16px;border-radius:50%;background:#ef4444;border:3px solid white;box-shadow:0 2px 8px rgba(239,68,68,0.6);z-index:1;"></div>
            </div>`,
          iconSize: [32, 32],
          iconAnchor: [16, 16],
        });

        const marker = L.marker(latlng, { icon });
        marker.bindPopup(`
          <div style="font-family:sans-serif;min-width:180px;">
            <div style="font-weight:700;color:#ef4444;font-size:13px;margin-bottom:4px;">🚨 SOS Alert #${alert.id}</div>
            <div style="font-size:11px;color:#64748b;margin-bottom:2px;"><b>User:</b> ${alert.user_email ?? 'Unknown'}</div>
            <div style="font-size:11px;color:#64748b;"><b>Time:</b> ${formatRelative(alert.created_at)}</div>
            <div style="font-size:10px;color:#94a3b8;margin-top:4px;">${lat.toFixed(5)}, ${lng.toFixed(5)}</div>
          </div>
        `, { maxWidth: 220 });
        marker.addTo(map);
      });
    }

    // Complaint markers — BLUE (using a fixed location since complaints don't store lat/lng)
    // We cluster them around the SOS location as demonstration of activity
    if (showComplaints && sosAlerts.length > 0) {
      // Use centroid of SOS alerts as base; spread complaints around it
      const validSOS = sosAlerts.filter(a => !isNaN(parseFloat(a.lat)));
      if (validSOS.length > 0) {
        const baseLat = parseFloat(validSOS[0].lat);
        const baseLng = parseFloat(validSOS[0].long);

        complaints.slice(0, 20).forEach((comp, i) => {
          const offsetLat = baseLat + (Math.sin(i * 1.3) * 0.08);
          const offsetLng = baseLng + (Math.cos(i * 1.7) * 0.08);
          const latlng = L.latLng(offsetLat, offsetLng);
          markersAdded.push(latlng);

          const color = comp.status === 'Resolved' ? '#10b981' :
                        comp.status === 'Dispatched' ? '#3b82f6' :
                        comp.status === 'Terminated' ? '#6b7280' : '#f59e0b';

          const icon = L.divIcon({
            className: '',
            html: `<div style="width:12px;height:12px;border-radius:50%;background:${color};border:2px solid white;box-shadow:0 1px 4px rgba(0,0,0,0.3);"></div>`,
            iconSize: [12, 12],
            iconAnchor: [6, 6],
          });

          const marker = L.marker(latlng, { icon });
          marker.bindPopup(`
            <div style="font-family:sans-serif;min-width:180px;">
              <div style="font-weight:700;font-size:13px;margin-bottom:4px;">📋 ${comp.title}</div>
              <div style="font-size:11px;color:#64748b;margin-bottom:2px;"><b>Type:</b> ${comp.crime_type}</div>
              <div style="font-size:11px;color:#64748b;margin-bottom:2px;"><b>Status:</b> <span style="color:${color};font-weight:600;">${comp.status}</span></div>
              <div style="font-size:11px;color:#64748b;"><b>By:</b> ${comp.user_email}</div>
              <div style="font-size:10px;color:#94a3b8;margin-top:4px;">${formatRelative(comp.created_at)}</div>
            </div>
          `, { maxWidth: 220 });
          marker.addTo(map);
        });
      }
    }

    // Auto-fit map to markers if we have any
    if (markersAdded.length > 0) {
      if (markersAdded.length === 1) {
        map.setView(markersAdded[0], 13);
      } else {
        const bounds = L.latLngBounds(markersAdded);
        map.fitBounds(bounds.pad(0.4), { maxZoom: 13, animate: true });
      }
    }

  }, [sosAlerts, complaints, showSOS, showComplaints, loading]);

  const totalIncidents = sosAlerts.length + complaints.length;

  return (
    <div className="relative w-full h-[calc(100vh-80px)] overflow-hidden bg-slate-100 dark:bg-slate-900 animate-in fade-in duration-700">
      {/* Leaflet CSS ping animation */}
      <style>{`
        @keyframes ping {
          0%, 100% { transform: scale(1); opacity: 0.6; }
          50% { transform: scale(2); opacity: 0; }
        }
      `}</style>

      {/* The actual map */}
      <div ref={mapRef} className="absolute inset-0 w-full h-full z-0" />

      {/* Loading overlay */}
      {loading && (
        <div className="absolute inset-0 z-50 flex items-center justify-center bg-slate-900/60 backdrop-blur-sm">
          <div className="flex flex-col items-center gap-3 text-white">
            <span className="material-icons text-5xl animate-spin">location_on</span>
            <p className="font-semibold text-lg">Loading map data…</p>
          </div>
        </div>
      )}

      {/* Top-left: Stats */}
      <div className="absolute top-4 left-4 z-20 flex flex-col gap-3">
        <div className="glass px-4 py-3 rounded-xl shadow-lg border border-white/20 backdrop-blur-md bg-white/80 dark:bg-slate-900/80 flex items-center gap-4">
          <div className="flex items-center gap-2">
            <span className="w-3 h-3 rounded-full bg-red-500 animate-pulse"></span>
            <span className="text-sm font-bold text-slate-700 dark:text-slate-200">
              {sosAlerts.length} SOS Alert{sosAlerts.length !== 1 ? 's' : ''}
            </span>
          </div>
          <div className="w-px h-4 bg-slate-300 dark:bg-slate-600"></div>
          <div className="flex items-center gap-2">
            <span className="w-3 h-3 rounded-full bg-amber-500"></span>
            <span className="text-sm font-bold text-slate-700 dark:text-slate-200">
              {complaints.length} Report{complaints.length !== 1 ? 's' : ''}
            </span>
          </div>
          <div className="w-px h-4 bg-slate-300 dark:bg-slate-600"></div>
          <div className="flex items-center gap-2">
            <span className="material-icons text-primary text-base">assessment</span>
            <span className="text-sm font-bold text-slate-700 dark:text-slate-200">
              {totalIncidents} Total
            </span>
          </div>
        </div>
      </div>

      {/* Top-right: Layer controls */}
      <div className="absolute top-4 right-4 z-20 w-64">
        <div className="glass rounded-xl shadow-xl p-4 border border-white/20 backdrop-blur-md bg-white/80 dark:bg-slate-900/80">
          <h3 className="text-xs uppercase tracking-wider font-bold text-slate-500 dark:text-slate-400 mb-3 flex items-center gap-2">
            <span className="material-icons text-base">layers</span>
            Map Layers
          </h3>
          <div className="space-y-3">
            <label className="flex items-center justify-between cursor-pointer group">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 bg-red-100 dark:bg-red-900/30 rounded flex items-center justify-center">
                  <span className="material-icons text-red-500 text-base">emergency</span>
                </div>
                <div>
                  <span className="text-sm font-semibold text-slate-700 dark:text-slate-200">SOS Alerts</span>
                  <p className="text-[10px] text-slate-400">{sosAlerts.length} active</p>
                </div>
              </div>
              <input
                type="checkbox"
                checked={showSOS}
                onChange={e => setShowSOS(e.target.checked)}
                className="h-4 w-4 rounded text-red-500 focus:ring-red-500 cursor-pointer"
              />
            </label>

            <label className="flex items-center justify-between cursor-pointer group">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 bg-amber-100 dark:bg-amber-900/30 rounded flex items-center justify-center">
                  <span className="material-icons text-amber-500 text-base">report</span>
                </div>
                <div>
                  <span className="text-sm font-semibold text-slate-700 dark:text-slate-200">Complaints</span>
                  <p className="text-[10px] text-slate-400">{complaints.length} total</p>
                </div>
              </div>
              <input
                type="checkbox"
                checked={showComplaints}
                onChange={e => setShowComplaints(e.target.checked)}
                className="h-4 w-4 rounded text-amber-500 focus:ring-amber-500 cursor-pointer"
              />
            </label>
          </div>
        </div>

        {/* Status legend */}
        <div className="mt-3 glass rounded-xl shadow-xl p-4 border border-white/20 backdrop-blur-md bg-white/80 dark:bg-slate-900/80">
          <h3 className="text-xs uppercase tracking-wider font-bold text-slate-500 dark:text-slate-400 mb-3">Legend</h3>
          <div className="space-y-2">
            {[
              { color: 'bg-red-500', label: 'SOS Alert', pulse: true },
              { color: 'bg-amber-500', label: 'Pending' },
              { color: 'bg-blue-500', label: 'Dispatched' },
              { color: 'bg-emerald-500', label: 'Resolved' },
              { color: 'bg-gray-500', label: 'Terminated' },
            ].map(item => (
              <div key={item.label} className="flex items-center gap-2">
                <span className={`w-3 h-3 rounded-full flex-shrink-0 ${item.color} ${item.pulse ? 'animate-pulse' : ''}`}></span>
                <span className="text-xs text-slate-600 dark:text-slate-300 font-medium">{item.label}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Locate Me button — bottom right above zoom */}
      <div className="absolute bottom-24 right-4 z-20">
        <button
          onClick={locateMe}
          disabled={locating}
          title="Show my location"
          className="w-11 h-11 rounded-full bg-white dark:bg-slate-800 shadow-lg border border-slate-200 dark:border-slate-700 flex items-center justify-center hover:bg-blue-50 dark:hover:bg-blue-900/20 active:scale-95 transition-all disabled:opacity-60 disabled:cursor-not-allowed"
        >
          {locating
            ? <span className="material-icons text-blue-500 text-xl animate-spin">refresh</span>
            : <span className="material-icons text-blue-600 text-xl">my_location</span>
          }
        </button>
        {locationError && (
          <div className="absolute right-14 top-1/2 -translate-y-1/2 bg-red-600 text-white text-xs font-semibold px-3 py-2 rounded-lg shadow-lg whitespace-nowrap">
            {locationError}
          </div>
        )}
      </div>

      {/* Bottom: Recent SOS list */}
      {!loading && sosAlerts.length > 0 && (
        <div className="absolute bottom-4 left-4 z-20 w-80">
          <div className="glass rounded-xl shadow-xl border border-white/20 backdrop-blur-md bg-white/80 dark:bg-slate-900/80 overflow-hidden">
            <div className="px-4 py-3 border-b border-slate-200/50 dark:border-slate-700/50 flex items-center justify-between">
              <h3 className="text-xs font-bold uppercase tracking-wider text-slate-500 dark:text-slate-400 flex items-center gap-1.5">
                <span className="w-2 h-2 rounded-full bg-red-500 animate-pulse"></span>
                Recent SOS Alerts
              </h3>
              <span className="text-[10px] text-slate-400 bg-slate-100 dark:bg-slate-800 px-2 py-0.5 rounded">{sosAlerts.length} total</span>
            </div>
            <div className="max-h-40 overflow-y-auto divide-y divide-slate-100 dark:divide-slate-800">
              {sosAlerts.slice(0, 5).map(alert => (
                <div
                  key={alert.id}
                  className="px-4 py-2.5 flex items-center gap-3 hover:bg-red-50 dark:hover:bg-red-900/10 transition-colors cursor-pointer"
                  onClick={() => {
                    const lat = parseFloat(alert.lat);
                    const lng = parseFloat(alert.long);
                    if (!isNaN(lat) && !isNaN(lng) && mapInstanceRef.current) {
                      mapInstanceRef.current.flyTo([lat, lng], 14, { duration: 1.5 });
                    }
                  }}
                >
                  <span className="material-icons text-red-500 text-base flex-shrink-0">emergency</span>
                  <div className="flex-1 min-w-0">
                    <p className="text-xs font-semibold text-slate-700 dark:text-slate-200 truncate">
                      #{alert.id} — {alert.user_email ?? 'Unknown user'}
                    </p>
                    <p className="text-[10px] text-slate-400">
                      {parseFloat(alert.lat).toFixed(4)}, {parseFloat(alert.long).toFixed(4)} · {formatRelative(alert.created_at)}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      )}

      {/* Empty state if no data */}
      {!loading && sosAlerts.length === 0 && complaints.length === 0 && (
        <div className="absolute inset-0 z-20 flex items-center justify-center pointer-events-none">
          <div className="glass px-8 py-6 rounded-2xl shadow-xl border border-white/20 backdrop-blur-md bg-white/80 dark:bg-slate-900/80 text-center">
            <span className="material-icons text-5xl text-slate-300 mb-2">location_off</span>
            <p className="text-slate-600 dark:text-slate-300 font-semibold">No incident data yet</p>
            <p className="text-sm text-slate-400 mt-1">SOS alerts and complaints will appear here as pins</p>
          </div>
        </div>
      )}
    </div>
  );
};

export default HeatMapPage;
