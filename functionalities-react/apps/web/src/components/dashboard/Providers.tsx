import React, { useEffect, useMemo, useState } from 'react';
import { RefreshCw, ShieldCheck, Users, MapPin, EyeOff } from 'lucide-react';

interface Provider {
  consent_id: string;
  user_did: string;
  requester_name?: string;
  purpose?: string;
  disclosure_mode: string;
  region?: string;
  approved_fields: string[];
  credit_offer?: string;
  expires_at: string;
  status: string;
  created_at: string;
}

interface RegionalCohort {
  requester_name: string;
  region: string;
  disclosure_mode: string;
  consent_count: number;
  minimum_cohort_size: number;
  status: string;
  approved_fields: string[];
  insight: {
    privacy_note?: string;
    release_state?: string;
  };
}

interface ProviderResponse {
  total_active_consents: number;
  identifiable_provider_count: number;
  anonymous_cohort_count: number;
  providers: Provider[];
  regional_cohorts: RegionalCohort[];
}

const Providers: React.FC = () => {
  const [data, setData] = useState<ProviderResponse | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const visibleProviders = useMemo(() => data?.providers || [], [data]);
  const cohorts = useMemo(() => data?.regional_cohorts || [], [data]);

  useEffect(() => {
    refresh();
  }, []);

  const refresh = async () => {
    setIsLoading(true);
    setError('');
    try {
      const response = await fetch('/api/v1/enterprise/consent-providers');
      if (!response.ok) {
        throw new Error(`Provider API returned ${response.status}`);
      }
      setData(await response.json());
    } catch (err) {
      setError('Unable to load consent providers. Start the FastAPI backend, approve a request in Flutter, then refresh.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
      <header className="flex justify-between gap-6 items-start">
        <div>
          <div className="inline-flex items-center gap-2 bg-emerald-50 text-emerald-700 border border-emerald-100 rounded-full px-3 py-1 text-[10px] font-black uppercase tracking-widest mb-4">
            Enterprise consent inventory
          </div>
          <h1 className="text-4xl font-black tracking-tight text-slate-900 mb-2">Consent Providers</h1>
          <p className="text-slate-500 font-medium max-w-3xl">
            See which pseudonymous users have granted scoped access, and which regional cohorts are available only as
            anonymous aggregate insight.
          </p>
        </div>
        <button
          onClick={refresh}
          className="flex items-center gap-2 bg-white border border-slate-200 px-4 py-2 rounded-2xl text-xs font-black uppercase tracking-widest"
        >
          <RefreshCw size={14} className={isLoading ? 'animate-spin' : ''} /> Refresh
        </button>
      </header>

      {error && <div className="bg-rose-50 border border-rose-100 text-rose-700 rounded-2xl p-4 text-sm font-bold">{error}</div>}

      <div className="grid md:grid-cols-3 gap-4">
        <Metric icon={<ShieldCheck size={18} />} label="Active consents" value={String(data?.total_active_consents || 0)} />
        <Metric icon={<Users size={18} />} label="Provider records" value={String(data?.identifiable_provider_count || 0)} />
        <Metric icon={<EyeOff size={18} />} label="Anonymous cohorts" value={String(data?.anonymous_cohort_count || 0)} />
      </div>

      <section className="bg-white border border-slate-200 rounded-[2rem] p-8 shadow-sm">
        <div className="flex items-center gap-3 mb-6">
          <div className="bg-blue-50 p-3 rounded-2xl text-blue-600">
            <Users size={22} />
          </div>
          <div>
            <h2 className="text-xl font-black text-slate-900">Consented providers</h2>
            <p className="text-sm text-slate-500">Visible only for verified proof or limited raw sharing modes.</p>
          </div>
        </div>

        <div className="space-y-3">
          {visibleProviders.length === 0 ? (
            <p className="text-sm text-slate-500">No provider-level consents yet. Approve a verified proof or limited raw request in Flutter.</p>
          ) : (
            visibleProviders.map((provider) => (
              <div key={provider.consent_id} className="border border-slate-100 rounded-2xl p-4 flex flex-col lg:flex-row lg:items-center lg:justify-between gap-4">
                <div>
                  <div className="flex items-center gap-2 mb-2">
                    <span className="text-[10px] font-black uppercase tracking-widest bg-slate-100 text-slate-600 px-2 py-1 rounded-full">
                      {provider.disclosure_mode.replaceAll('_', ' ')}
                    </span>
                    <span className="text-[10px] font-black uppercase tracking-widest text-slate-400">{provider.region || 'India'}</span>
                  </div>
                  <p className="font-black text-slate-900">{maskDid(provider.user_did)}</p>
                  <p className="text-sm text-slate-500">{provider.requester_name || 'Enterprise Partner'} - {provider.purpose || 'Approved use'}</p>
                </div>
                <div className="lg:text-right">
                  <p className="text-[10px] font-black uppercase tracking-widest text-slate-400 mb-2">Approved fields</p>
                  <FieldList fields={provider.approved_fields} alignRight />
                  <p className="text-[10px] text-slate-400 mt-2">Expires {new Date(provider.expires_at).toLocaleDateString()}</p>
                </div>
              </div>
            ))
          )}
        </div>
      </section>

      <section className="bg-white border border-slate-200 rounded-[2rem] p-8 shadow-sm">
        <div className="flex items-center gap-3 mb-6">
          <div className="bg-emerald-50 p-3 rounded-2xl text-emerald-600">
            <MapPin size={22} />
          </div>
          <div>
            <h2 className="text-xl font-black text-slate-900">Regional anonymous cohorts</h2>
            <p className="text-sm text-slate-500">Individual users stay hidden until the enterprise uses a non-anonymous disclosure mode.</p>
          </div>
        </div>

        <div className="grid lg:grid-cols-2 gap-4">
          {cohorts.length === 0 ? (
            <p className="text-sm text-slate-500">No anonymized regional cohorts yet. Approve regional anonymized requests in Flutter.</p>
          ) : (
            cohorts.map((cohort) => (
              <div key={`${cohort.requester_name}-${cohort.region}-${cohort.disclosure_mode}`} className="border border-slate-100 rounded-2xl p-5">
                <div className="flex items-start justify-between gap-3 mb-5">
                  <div>
                    <p className="text-[10px] font-black uppercase tracking-widest text-slate-400 mb-1">{cohort.requester_name}</p>
                    <h3 className="text-lg font-black text-slate-900">{cohort.region}</h3>
                  </div>
                  <span className={`text-[10px] font-black uppercase tracking-widest px-2 py-1 rounded-full ${cohort.status === 'available' ? 'bg-emerald-50 text-emerald-700' : 'bg-amber-50 text-amber-700'}`}>
                    {cohort.status.replaceAll('_', ' ')}
                  </span>
                </div>
                <div className="grid grid-cols-2 gap-3 mb-5">
                  <SmallMetric label="Consents" value={String(cohort.consent_count)} />
                  <SmallMetric label="Threshold" value={String(cohort.minimum_cohort_size)} />
                </div>
                <FieldList fields={cohort.approved_fields} />
                <p className="text-xs text-slate-500 mt-4">{cohort.insight.privacy_note}</p>
              </div>
            ))
          )}
        </div>
      </section>
    </div>
  );
};

const Metric: React.FC<{ icon: React.ReactNode; label: string; value: string }> = ({ icon, label, value }) => (
  <div className="bg-white border border-slate-200 rounded-2xl p-5 shadow-sm">
    <div className="text-blue-600 mb-4">{icon}</div>
    <p className="text-[10px] font-black uppercase tracking-widest text-slate-400 mb-2">{label}</p>
    <p className="text-3xl font-black text-slate-900">{value}</p>
  </div>
);

const SmallMetric: React.FC<{ label: string; value: string }> = ({ label, value }) => (
  <div className="bg-slate-50 border border-slate-100 rounded-xl p-3">
    <p className="text-[10px] font-black uppercase tracking-widest text-slate-400 mb-1">{label}</p>
    <p className="text-xl font-black text-slate-900">{value}</p>
  </div>
);

const FieldList: React.FC<{ fields: string[]; alignRight?: boolean }> = ({ fields, alignRight = false }) => (
  <div className={`flex flex-wrap gap-2 ${alignRight ? 'lg:justify-end' : ''}`}>
    {(fields.length ? fields : ['No fields']).map((field) => (
      <span key={field} className="text-[10px] font-bold bg-slate-50 border border-slate-200 text-slate-500 px-3 py-1 rounded-full uppercase">
        {field.replaceAll('_', ' ')}
      </span>
    ))}
  </div>
);

function maskDid(did: string): string {
  if (did.length <= 18) return did;
  return `${did.slice(0, 14)}...${did.slice(-6)}`;
}

export default Providers;
