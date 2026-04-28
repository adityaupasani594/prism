import React, { useEffect, useState } from 'react';
import { ArrowRight, CheckCircle, EyeOff, FileCheck2, Info, Layers3, ShieldCheck } from 'lucide-react';

type DisclosureMode = 'regional_anonymized' | 'verified_proof' | 'limited_raw';

interface DataRequest {
  id: string;
  requester_name: string;
  title: string;
  description: string;
  purpose: string;
  category?: string;
  scope: { fields?: string[] };
  disclosure_modes: DisclosureMode[];
  credit_offer: string;
  reward_amount: string;
  region?: string;
  minimum_cohort_size: number;
  duration_days: number;
}

interface ConsentExchangeResponse {
  status: string;
  payout_id: string;
  summary: string;
  credit_offer: string;
  disclosure_mode: DisclosureMode;
  consent_id: string;
  output_type: string;
}

const modeCopy: Record<DisclosureMode, { title: string; detail: string; icon: React.ElementType }> = {
  regional_anonymized: {
    title: 'Regional anonymized insight',
    detail: 'Default mode. The enterprise receives aggregate regional intelligence, not individual records.',
    icon: Layers3,
  },
  verified_proof: {
    title: 'Verified proof',
    detail: 'PRISM proves eligibility without exposing raw identity documents or sensitive fields.',
    icon: FileCheck2,
  },
  limited_raw: {
    title: 'Limited field sharing',
    detail: 'Only approved fields are made available through PRISM Shield with expiry and audit logs.',
    icon: EyeOff,
  },
};

const fallbackRequests: DataRequest[] = [
  {
    id: 'demo-fallback',
    requester_name: 'Tesla India',
    title: 'EV Consumer Interest in Pune',
    description: 'Privacy-preserving regional demand signals for EV charging and purchase intent.',
    purpose: 'EV infrastructure planning',
    category: 'Regional mobility insight',
    scope: { fields: ['ev_interest', 'charging_access', 'locality'] },
    disclosure_modes: ['regional_anonymized'],
    credit_offer: '750 partner credits',
    reward_amount: '750 credits',
    region: 'Pune',
    minimum_cohort_size: 100,
    duration_days: 30,
  },
];

const Marketplace: React.FC = () => {
  const [requests, setRequests] = useState<DataRequest[]>([]);
  const [selectedRequest, setSelectedRequest] = useState<DataRequest | null>(null);
  const [selectedMode, setSelectedMode] = useState<DisclosureMode>('regional_anonymized');
  const [isProcessing, setIsProcessing] = useState(false);
  const [consentResult, setConsentResult] = useState<ConsentExchangeResponse | null>(null);

  useEffect(() => {
    fetchRequests();
  }, []);

  const fetchRequests = async () => {
    try {
      const response = await fetch('/api/v1/consent-exchange/requests');
      const data = await response.json();
      setRequests(Array.isArray(data) && data.length > 0 ? data : fallbackRequests);
    } catch (err) {
      console.error('Failed to fetch consent exchange requests');
      setRequests(fallbackRequests);
    }
  };

  const openRequest = (request: DataRequest) => {
    setSelectedRequest(request);
    setSelectedMode(request.disclosure_modes?.[0] || 'regional_anonymized');
    setConsentResult(null);
  };

  const approveConsent = async () => {
    if (!selectedRequest || selectedRequest.id.startsWith('demo-')) return;
    setIsProcessing(true);
    setConsentResult(null);

    try {
      const response = await fetch('/api/v1/consent-exchange/respond', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          user_did: 'did:prism:user_123',
          request_id: selectedRequest.id,
          disclosure_mode: selectedMode,
          requested_scope: selectedRequest.scope,
        }),
      });
      const result = await response.json();
      setConsentResult(result);
    } catch (err) {
      console.error('Error processing consent exchange approval');
    } finally {
      setIsProcessing(false);
    }
  };

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
      <header>
        <div className="inline-flex items-center gap-2 bg-blue-50 text-blue-700 border border-blue-100 rounded-full px-3 py-1 text-[10px] font-black uppercase tracking-widest mb-4">
          Enterprise data requests
        </div>
        <h1 className="text-4xl font-black tracking-tight text-slate-900 mb-2">Consent Exchange</h1>
        <p className="text-slate-500 font-medium max-w-3xl">
          Enterprises request data with a declared purpose, scope, duration, and value credits. PRISM defaults to
          anonymized regional insight instead of raw data sharing.
        </p>
      </header>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {requests.map((req) => (
          <article key={req.id} className="bg-white border border-slate-200 rounded-3xl p-6 shadow-sm hover:shadow-md transition-shadow">
            <div className="flex justify-between items-start mb-4">
              <div className="bg-blue-50 p-3 rounded-xl">
                <ShieldCheck className="text-blue-600 w-6 h-6" />
              </div>
              <span className="text-xs font-black text-emerald-700 bg-emerald-50 px-3 py-1 rounded-full">
                {req.credit_offer || req.reward_amount}
              </span>
            </div>
            <p className="text-[10px] font-black uppercase tracking-widest text-slate-400 mb-2">{req.category || 'Enterprise request'}</p>
            <h3 className="text-xl font-black text-slate-900 mb-1">{req.title}</h3>
            <p className="text-sm text-slate-500 mb-3 font-medium">{req.requester_name}</p>
            <p className="text-slate-600 text-sm mb-5 line-clamp-3">{req.description}</p>
            <div className="flex flex-wrap gap-2 mb-6">
              {(req.scope?.fields || []).map((field) => (
                <span key={field} className="text-[10px] font-bold bg-slate-100 text-slate-500 px-2 py-1 rounded-full uppercase">
                  {field.replaceAll('_', ' ')}
                </span>
              ))}
            </div>
            <button onClick={() => openRequest(req)} className="w-full flex items-center justify-center gap-2 bg-slate-900 text-white py-3 rounded-xl font-semibold hover:bg-slate-800 transition-colors">
              Review request <ArrowRight size={18} />
            </button>
          </article>
        ))}
      </div>

      {selectedRequest && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-3xl max-w-3xl w-full max-h-[90vh] overflow-y-auto shadow-2xl">
            <div className="p-8">
              <div className="flex justify-between items-start mb-6">
                <div>
                  <h2 className="text-2xl font-black text-slate-900">Consent review</h2>
                  <p className="text-slate-500">Purpose-bound, scope-bound, and time-limited.</p>
                </div>
                <button onClick={() => setSelectedRequest(null)} className="text-slate-400 hover:text-slate-600">
                  <ArrowRight className="rotate-180" />
                </button>
              </div>

              <div className="grid md:grid-cols-2 gap-4 mb-6">
                <Detail label="Purpose" value={selectedRequest.purpose} />
                <Detail label="Access window" value={`${selectedRequest.duration_days} days`} />
                <Detail label="Region" value={selectedRequest.region || 'India'} />
                <Detail label="Value exchange" value={selectedRequest.credit_offer || selectedRequest.reward_amount} />
              </div>

              <h3 className="text-sm font-black uppercase tracking-widest text-slate-500 mb-3">Disclosure mode</h3>
              <div className="grid gap-3 mb-6">
                {(selectedRequest.disclosure_modes || ['regional_anonymized']).map((mode) => {
                  const Icon = modeCopy[mode].icon;
                  const active = selectedMode === mode;
                  return (
                    <button key={mode} onClick={() => setSelectedMode(mode)} className={`text-left border rounded-2xl p-4 transition-all ${active ? 'border-blue-500 bg-blue-50' : 'border-slate-200 bg-white hover:border-slate-300'}`}>
                      <div className="flex gap-3">
                        <Icon className={active ? 'text-blue-600' : 'text-slate-400'} />
                        <div>
                          <p className="font-black text-slate-900">{modeCopy[mode].title}</p>
                          <p className="text-sm text-slate-500">{modeCopy[mode].detail}</p>
                        </div>
                      </div>
                    </button>
                  );
                })}
              </div>

              {isProcessing ? (
                <div className="flex flex-col items-center justify-center py-10">
                  <div className="animate-spin rounded-full h-10 w-10 border-b-2 border-blue-600 mb-4" />
                  <p className="text-slate-600">Gemini is preparing a plain-language notice...</p>
                </div>
              ) : consentResult ? (
                <div className="bg-emerald-50 border border-emerald-100 rounded-2xl p-6">
                  <div className="flex gap-4">
                    <CheckCircle className="text-emerald-600 shrink-0 mt-1" size={24} />
                    <div>
                      <h4 className="font-bold text-emerald-900">Consent approved</h4>
                      <p className="text-emerald-700 text-sm mb-2">
                        {consentResult.credit_offer} reserved. Consent ID: {consentResult.consent_id}
                      </p>
                      <p className="text-xs text-emerald-800 whitespace-pre-line">{consentResult.summary}</p>
                    </div>
                  </div>
                </div>
              ) : (
                <div className="flex gap-4">
                  <button onClick={() => setSelectedRequest(null)} className="flex-1 bg-slate-100 text-slate-700 font-bold py-4 rounded-2xl hover:bg-slate-200 transition-colors">
                    Decline
                  </button>
                  <button onClick={approveConsent} disabled={selectedRequest.id.startsWith('demo-')} className="flex-1 bg-blue-600 disabled:bg-slate-300 text-white font-bold py-4 rounded-2xl hover:bg-blue-700 transition-colors flex items-center justify-center gap-2">
                    <ShieldCheck size={20} /> Approve with PRISM
                  </button>
                </div>
              )}
            </div>
            <div className="bg-slate-50 p-4 text-center border-t border-slate-100">
              <p className="text-[10px] text-slate-400 uppercase tracking-widest font-bold flex items-center justify-center gap-1">
                <Info size={12} /> Consent starts the protected journey; PRISM Shield enforces it after approval.
              </p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

const Detail: React.FC<{ label: string; value: string }> = ({ label, value }) => (
  <div className="bg-slate-50 rounded-2xl p-5 border border-slate-100">
    <p className="text-[10px] font-black uppercase tracking-widest text-slate-400 mb-2">{label}</p>
    <p className="font-bold text-slate-900">{value}</p>
  </div>
);

export default Marketplace;
