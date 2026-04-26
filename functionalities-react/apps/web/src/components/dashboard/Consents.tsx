import React, { useEffect, useState } from 'react';
import { Shield, Trash2, Clock, CheckCircle, AlertCircle } from 'lucide-react';

interface ConsentRecord {
  id: string;
  purpose_tag: string;
  data_fields: any;
  expiry_timestamp: string;
  status: string;
  created_at: string;
}

const Consents: React.FC = () => {
  const [consents, setConsents] = useState<ConsentRecord[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [revokingId, setRevokingId] = useState<string | null>(null);
  const userDid = "did:prism:user_123";

  const fetchConsents = async () => {
    setIsLoading(true);
    try {
      const response = await fetch(`/api/v1/consent/status?did=${userDid}`);
      const data = await response.json();
      setConsents(data.consents || []);
    } catch (error) {
      console.error("Error fetching consents:", error);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchConsents();
  }, []);

  const handleRevoke = async (id: string) => {
    try {
      const response = await fetch(`/api/v1/revoke-consent/${id}`, { method: 'POST' });
      const result = await response.json();
      if (result.status === "success" || result.status === "already_revoked") {
        fetchConsents(); // Refresh list
      }
    } catch (error) {
      console.error("Error revoking consent:", error);
      alert("Failed to revoke consent. Please try again.");
    } finally {
      setRevokingId(null);
    }
  };

  if (isLoading) {
    return (
      <div className="flex flex-col items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-prism-primary mb-4"></div>
        <p className="text-slate-400 font-medium italic">Loading your consent artifacts...</p>
      </div>
    );
  }

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
      <div className="flex justify-between items-end">
        <div>
          <h1 className="text-4xl font-black tracking-tight text-slate-900 mb-2 underline decoration-prism-accent decoration-4 underline-offset-8">
            Consent Governance
          </h1>
          <p className="text-slate-500 font-medium">Manage and audit your active data disclosure permissions.</p>
        </div>
        <div className="bg-prism-primary/10 text-prism-primary px-4 py-2 rounded-full text-xs font-black uppercase tracking-widest border border-prism-primary/20">
          DPDP Audit Ready
        </div>
      </div>

      {consents.length === 0 ? (
        <div className="bg-white border-2 border-dashed border-slate-200 rounded-3xl p-20 text-center">
          <div className="bg-slate-50 w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-6">
            <Shield className="text-slate-300 w-10 h-10" />
          </div>
          <h3 className="text-xl font-bold text-slate-900 mb-2">No Active Consents</h3>
          <p className="text-slate-500 max-w-sm mx-auto">You haven't granted any data permissions yet. Head over to the Marketplace to begin earning.</p>
        </div>
      ) : (
        <div className="grid gap-4">
          {consents.map((consent) => (
            <div key={consent.id} className="bg-white border border-slate-200 rounded-3xl p-6 hover:shadow-xl hover:shadow-slate-200/50 transition-all group">
              <div className="flex justify-between items-start">
                <div className="flex gap-4">
                  <div className="bg-prism-primary/5 p-4 rounded-2xl group-hover:scale-110 transition-transform">
                    <Shield className="text-prism-primary w-6 h-6" />
                  </div>
                  <div>
                    <div className="flex items-center gap-2 mb-1">
                      <h3 className="font-black text-lg text-slate-900">{consent.purpose_tag}</h3>
                      {consent.status === 'Active' ? (
                        <div className="flex items-center gap-1 bg-emerald-50 text-emerald-600 px-2 py-0.5 rounded-md text-[10px] font-black uppercase tracking-tighter border border-emerald-100 italic">
                          <CheckCircle size={10} /> Active
                        </div>
                      ) : (
                        <div className="flex items-center gap-1 bg-rose-50 text-rose-600 px-2 py-0.5 rounded-md text-[10px] font-black uppercase tracking-tighter border border-rose-100 italic">
                          <AlertCircle size={10} /> {consent.status}
                        </div>
                      )}
                    </div>
                    <div className="flex flex-wrap gap-2 mb-4">
                      {Object.keys(consent.data_fields).map(field => (
                        <span key={field} className="text-[10px] font-bold bg-slate-100 text-slate-500 px-2 py-1 rounded-full uppercase tracking-widest">
                          {field}
                        </span>
                      ))}
                    </div>
                    <div className="flex items-center gap-6 text-xs text-slate-400 font-bold uppercase tracking-widest">
                      <div className="flex items-center gap-1.5">
                        <Clock size={12} className="text-slate-300" />
                        Expires: {new Date(consent.expiry_timestamp).toLocaleDateString()}
                      </div>
                      <div>
                        ID: {consent.id.substring(0, 8)}...
                      </div>
                    </div>
                  </div>
                </div>
                
                {consent.status === 'Active' && (
                  <div className="flex gap-2">
                    {revokingId === consent.id ? (
                      <div className="flex items-center gap-2 animate-in slide-in-from-right-2 duration-300">
                        <button 
                          onClick={() => handleRevoke(consent.id)}
                          className="bg-rose-500 text-white px-4 py-2 rounded-2xl text-[10px] font-black uppercase tracking-widest shadow-lg shadow-rose-500/20"
                        >
                          Confirm Revoke
                        </button>
                        <button 
                          onClick={() => setRevokingId(null)}
                          className="bg-slate-100 text-slate-500 px-4 py-2 rounded-2xl text-[10px] font-black uppercase tracking-widest"
                        >
                          Cancel
                        </button>
                      </div>
                    ) : (
                      <button 
                        onClick={() => setRevokingId(consent.id)}
                        className="opacity-0 group-hover:opacity-100 flex items-center gap-2 bg-rose-50 text-rose-500 hover:bg-rose-500 hover:text-white px-4 py-2 rounded-2xl text-xs font-black uppercase tracking-widest transition-all transform hover:-translate-y-1 active:scale-95 border border-rose-100"
                      >
                        <Trash2 size={14} /> Revoke Access
                      </button>
                    )}
                  </div>
                )}
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export default Consents;
