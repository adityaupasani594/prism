import React, { useEffect, useMemo, useState } from 'react';
import { AlertTriangle, CheckCircle2, KeyRound, RefreshCw, ShieldCheck, Terminal } from 'lucide-react';

interface ConsentRecord {
  id: string;
  requester_name?: string;
  purpose_tag: string;
  purpose?: string;
  disclosure_mode?: string;
  scope?: { fields?: string[] };
  data_fields?: Record<string, unknown>;
  expiry_timestamp: string;
  status: string;
}

interface AccessEvent {
  id: string;
  requester_name: string;
  tool_name?: string;
  purpose: string;
  requested_fields: string[];
  resource?: string;
  decision: string;
  reason: string;
  is_violation: boolean;
  created_at: string;
}

const userDid = 'did:prism:user_123';

const Shield: React.FC = () => {
  const [consents, setConsents] = useState<ConsentRecord[]>([]);
  const [events, setEvents] = useState<AccessEvent[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [lastDecision, setLastDecision] = useState('');

  const activeConsent = useMemo(() => consents.find((c) => c.status === 'Active') || consents[0], [consents]);
  const allowedFields = useMemo(() => extractFields(activeConsent), [activeConsent]);
  const approvedPurpose = activeConsent?.purpose || activeConsent?.purpose_tag || 'Approved data use';
  const requesterName = activeConsent?.requester_name || activeConsent?.purpose_tag?.replace('Consent Exchange: ', '') || 'Enterprise Partner';

  useEffect(() => {
    refresh();
  }, []);

  const refresh = async () => {
    setIsLoading(true);
    try {
      const [consentResponse, auditResponse] = await Promise.all([
        fetch(`/api/v1/consent/status?did=${userDid}`),
        fetch(`/api/v1/shield/audit-log?did=${userDid}`),
      ]);
      const consentData = await consentResponse.json();
      const auditData = await auditResponse.json();
      setConsents(consentData.consents || []);
      setEvents(Array.isArray(auditData) ? auditData : []);
    } catch (err) {
      console.error('Failed to refresh Shield dashboard');
      setLastDecision('Unable to reach PRISM API. Start the FastAPI backend, then refresh.');
    } finally {
      setIsLoading(false);
    }
  };

  const simulate = async (mode: 'allowed' | 'overscope' | 'wrong-purpose') => {
    if (!activeConsent) {
      setLastDecision('Create a consent from Consent Exchange first, then run Shield checks.');
      return;
    }

    const requestedFields =
      mode === 'overscope'
        ? [...allowedFields, 'workspace_env_vars', 'private_email']
        : allowedFields.length > 0
          ? allowedFields
          : ['approved_signal'];

    const purpose = mode === 'wrong-purpose' ? 'Unapproved AI workspace analysis' : approvedPurpose;
    const resource = mode === 'overscope' ? 'google_workspace_sensitive_assets' : 'approved_consented_dataset';

    try {
      const response = await fetch('/api/v1/shield/access-check', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          user_did: userDid,
          consent_id: activeConsent.id,
          requester_name: requesterName,
          purpose,
          requested_fields: requestedFields,
          resource,
          tool_name: 'Enterprise AI Connector',
        }),
      });
      const result = await response.json();
      setLastDecision(`${String(result.decision).toUpperCase()}: ${result.reason}`);
      await refresh();
    } catch (err) {
      setLastDecision('Shield check failed. Confirm the backend is running.');
    }
  };

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
      <header className="flex justify-between gap-6 items-start">
        <div>
          <div className="inline-flex items-center gap-2 bg-blue-50 text-blue-700 border border-blue-100 rounded-full px-3 py-1 text-[10px] font-black uppercase tracking-widest mb-4">
            Digital Asset Protection
          </div>
          <h1 className="text-4xl font-black tracking-tight text-slate-900 mb-2">PRISM Shield</h1>
          <p className="text-slate-500 font-medium max-w-3xl">
            Enterprise access governance for personal data. Shield enforces purpose, scope, expiry, and audit logging after
            the user grants consent in the Android app.
          </p>
        </div>
        <button
          onClick={refresh}
          className="flex items-center gap-2 bg-white border border-slate-200 px-4 py-2 rounded-2xl text-xs font-black uppercase tracking-widest"
        >
          <RefreshCw size={14} className={isLoading ? 'animate-spin' : ''} /> Refresh
        </button>
      </header>

      <div className="grid lg:grid-cols-3 gap-6">
        <section className="lg:col-span-2 bg-white border border-slate-200 rounded-[2rem] p-8 shadow-sm">
          <div className="flex gap-4 items-start mb-8">
            <div className="bg-blue-50 p-3 rounded-2xl">
              <KeyRound className="text-blue-600" />
            </div>
            <div>
              <h2 className="text-xl font-black text-slate-900">Active consent policy</h2>
              <p className="text-sm text-slate-500">
                {activeConsent
                  ? `${requesterName} can access approved data for: ${approvedPurpose}`
                  : 'No active policy yet. Approve a Consent Exchange request first.'}
              </p>
            </div>
          </div>

          <div className="grid md:grid-cols-3 gap-4 mb-8">
            <Metric label="Disclosure" value={activeConsent?.disclosure_mode?.replaceAll('_', ' ') || 'None'} />
            <Metric label="Approved fields" value={allowedFields.length ? String(allowedFields.length) : '0'} />
            <Metric label="Status" value={activeConsent?.status || 'No consent'} />
          </div>

          <div className="bg-slate-50 border border-slate-100 rounded-2xl p-5 mb-8">
            <p className="text-[10px] font-black uppercase tracking-widest text-slate-400 mb-3">Allowed scope</p>
            <div className="flex flex-wrap gap-2">
              {(allowedFields.length ? allowedFields : ['No approved fields']).map((field) => (
                <span key={field} className="text-[10px] font-bold bg-white border border-slate-200 text-slate-500 px-3 py-1 rounded-full uppercase">
                  {field.replaceAll('_', ' ')}
                </span>
              ))}
            </div>
          </div>

          <div className="grid md:grid-cols-3 gap-3">
            <button onClick={() => simulate('allowed')} className="bg-emerald-600 text-white rounded-2xl p-4 font-black text-xs uppercase tracking-widest flex items-center justify-center gap-2">
              <CheckCircle2 size={16} /> Allowed
            </button>
            <button onClick={() => simulate('overscope')} className="bg-rose-600 text-white rounded-2xl p-4 font-black text-xs uppercase tracking-widest flex items-center justify-center gap-2">
              <AlertTriangle size={16} /> Over-scope
            </button>
            <button onClick={() => simulate('wrong-purpose')} className="bg-amber-500 text-white rounded-2xl p-4 font-black text-xs uppercase tracking-widest flex items-center justify-center gap-2">
              <ShieldCheck size={16} /> Wrong purpose
            </button>
          </div>

          {lastDecision && <div className="mt-6 bg-slate-900 text-white rounded-2xl p-4 text-sm font-bold">{lastDecision}</div>}
        </section>

        <aside className="bg-slate-900 text-white rounded-[2rem] p-8 relative overflow-hidden">
          <Terminal className="absolute right-6 top-6 text-white/10" size={110} />
          <p className="text-[10px] font-black uppercase tracking-widest text-blue-300 mb-5">Breach containment</p>
          <h3 className="text-2xl font-black tracking-tight mb-4">Broad AI tool access becomes narrow, temporary access.</h3>
          <p className="text-white/60 text-sm leading-relaxed">
            In a Vercel-style third-party AI compromise, PRISM does not claim to prevent the compromise. It limits the blast
            radius by blocking access outside approved purpose and scope.
          </p>
        </aside>
      </div>

      <section className="bg-white border border-slate-200 rounded-[2rem] p-8">
        <h2 className="text-xl font-black text-slate-900 mb-6">Shield audit log</h2>
        <div className="space-y-3">
          {events.length === 0 ? (
            <p className="text-sm text-slate-500">No Shield access events yet. Run a simulation above.</p>
          ) : (
            events.map((event) => (
              <div key={event.id} className="flex items-start justify-between gap-4 border border-slate-100 rounded-2xl p-4">
                <div>
                  <div className="flex items-center gap-2 mb-1">
                    <span className={`text-[10px] font-black uppercase tracking-widest px-2 py-1 rounded-full ${event.decision === 'allowed' ? 'bg-emerald-50 text-emerald-700' : 'bg-rose-50 text-rose-700'}`}>
                      {event.decision}
                    </span>
                    <p className="font-bold text-slate-900">{event.tool_name || event.requester_name}</p>
                  </div>
                  <p className="text-sm text-slate-500">{event.reason}</p>
                  <p className="text-[10px] uppercase tracking-widest text-slate-400 mt-2">
                    {(event.requested_fields || []).join(', ') || 'No fields'} - {event.resource || 'No resource'}
                  </p>
                </div>
                <p className="text-[10px] text-slate-400 whitespace-nowrap">{new Date(event.created_at).toLocaleTimeString()}</p>
              </div>
            ))
          )}
        </div>
      </section>
    </div>
  );
};

const Metric: React.FC<{ label: string; value: string }> = ({ label, value }) => (
  <div className="bg-slate-50 border border-slate-100 rounded-2xl p-5">
    <p className="text-[10px] font-black uppercase tracking-widest text-slate-400 mb-2">{label}</p>
    <p className="text-lg font-black text-slate-900 capitalize">{value}</p>
  </div>
);

function extractFields(consent?: ConsentRecord): string[] {
  const scopeFields = consent?.scope?.fields;
  if (Array.isArray(scopeFields)) return scopeFields.map(String);
  const approved = consent?.data_fields?.approved_fields;
  if (Array.isArray(approved)) return approved.map(String);
  return [];
}

export default Shield;
