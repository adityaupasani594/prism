import React, { useState, useEffect } from 'react';
import { Target, Search, AlertTriangle, ShieldCheck, Activity, Terminal, Sparkles, Loader2 } from 'lucide-react';

interface ScanResult {
  violations: string[];
  health_score: number;
  recommendations: string[];
}

const Compliance: React.FC = () => {
  const [consents, setConsents] = useState<any[]>([]);
  const [scanContent, setScanContent] = useState('');
  const [scanResult, setScanResult] = useState<ScanResult | null>(null);
  const [isScanning, setIsScanning] = useState(false);
  const userDid = "did:prism:user_123";

  useEffect(() => {
    fetchStats();
  }, []);

  const fetchStats = async () => {
    try {
      const response = await fetch(`/api/v1/consent/status?did=${userDid}`);
      const data = await response.json();
      setConsents(data.consents || []);
    } catch (err) {
      console.error("Stats fetch error");
    }
  };

  const calculateHealthScore = () => {
    if (consents.length === 0) return 100;
    const active = consents.filter(c => c.status === 'Active').length;
    const total = consents.length;
    // Simplified score: High number of active consents without revocation slightly lowers score to encourage "minimization"
    const score = Math.max(70, 100 - (active * 2)); 
    return score;
  };

  const handleScan = async () => {
    if (!scanContent.trim()) return;
    setIsScanning(true);
    setScanResult(null);

    try {
      const response = await fetch('/api/v1/compliance/scan', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ content: scanContent })
      });
      const data = await response.json();
      setScanResult(data);
    } catch (err) {
      console.error("Scan error");
    } finally {
      setIsScanning(false);
    }
  };

  const healthScore = calculateHealthScore();

  return (
    <div className="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-700">
      <header>
        <h1 className="text-4xl font-black tracking-tight text-slate-900 mb-2">Compliance Copilot</h1>
        <p className="text-slate-500 font-medium italic">Accountability & Static Analysis Layer (L2)</p>
      </header>

      <div className="grid md:grid-cols-3 gap-6">
        {/* Health Score Meter */}
        <div className="md:col-span-1 bg-white border border-slate-200 rounded-[2.5rem] p-8 flex flex-col items-center justify-center text-center shadow-2xl shadow-slate-200/50">
          <h3 className="text-xs font-black uppercase tracking-[0.3em] text-slate-400 mb-8">Consent Health</h3>
          <div className="relative mb-6">
            <svg className="w-32 h-32 transform -rotate-90">
              <circle cx="64" cy="64" r="58" stroke="currentColor" strokeWidth="12" fill="transparent" className="text-slate-100" />
              <circle cx="64" cy="64" r="58" stroke="currentColor" strokeWidth="12" fill="transparent" 
                strokeDasharray={364.4} strokeDashoffset={364.4 - (364.4 * healthScore) / 100}
                className={healthScore > 90 ? 'text-emerald-500' : healthScore > 75 ? 'text-prism-primary' : 'text-rose-500'} 
              />
            </svg>
            <div className="absolute inset-0 flex items-center justify-center">
              <span className="text-3xl font-black text-slate-900">{healthScore}</span>
            </div>
          </div>
          <div className="flex items-center gap-2 mb-2">
            <Activity size={14} className="text-emerald-500" />
            <p className="text-sm font-bold text-slate-900">Stable Integrity</p>
          </div>
          <p className="text-[10px] text-slate-400 font-bold leading-relaxed uppercase tracking-widest">
            Audit of your active <br/> data disclosures
          </p>
        </div>

        {/* Static Analysis Scanner */}
        <div className="md:col-span-2 bg-slate-900 rounded-[2.5rem] p-8 text-white relative overflow-hidden flex flex-col">
          <div className="absolute top-0 right-0 p-8 opacity-10 rotate-12">
            <Terminal size={100} />
          </div>

          <div className="flex items-center gap-3 mb-6">
            <div className="bg-prism-primary p-2 rounded-xl">
              <Search className="text-white w-5 h-5" />
            </div>
            <h2 className="text-xl font-black italic tracking-tighter uppercase">Static DPDP Analyzer</h2>
          </div>

          <p className="text-white/50 text-xs font-medium mb-6 leading-relaxed">
            Paste a microservice endpoint code or a specific privacy clause to detect potential <br/> violations of DPDP 2023.
          </p>

          <div className="relative group flex-1">
            <textarea
              value={scanContent}
              onChange={(e) => setScanContent(e.target.value)}
              placeholder="e.g. app.get('/user-data', (req, res) => { ... })"
              className="w-full h-40 bg-white/5 border-2 border-white/10 rounded-2xl p-6 font-mono text-xs outline-none focus:border-prism-primary transition-all resize-none mb-6"
            />
            
            <button
              onClick={handleScan}
              disabled={isScanning || !scanContent}
              className="w-full bg-prism-primary text-white py-4 rounded-3xl font-black uppercase tracking-widest shadow-xl shadow-prism-primary/20 hover:scale-[1.02] active:scale-95 transition-all flex items-center justify-center gap-2"
            >
              {isScanning ? (
                <><Loader2 className="animate-spin" /> Analyzing via Gemini...</>
              ) : (
                <><Sparkles size={18} /> Run Compliance Audit</>
              )}
            </button>
          </div>
        </div>
      </div>

      {scanResult && (
        <div className="animate-in fade-in slide-in-from-top-4 duration-500">
           <div className={`p-8 rounded-[2.5rem] border-2 ${scanResult.violations.length > 0 ? 'bg-rose-500/5 border-rose-500/20' : 'bg-emerald-500/5 border-emerald-500/20'}`}>
              <div className="flex justify-between items-start mb-8">
                <div>
                  <h3 className={`text-xl font-black uppercase tracking-tight mb-1 ${scanResult.violations.length > 0 ? 'text-rose-500' : 'text-emerald-500'}`}>
                    Audit Report: {scanResult.violations.length > 0 ? 'Critical Violations Found' : 'Clean Scan'}
                  </h3>
                  <p className="text-slate-400 text-xs font-bold uppercase tracking-widest">DPDP 2023 Statutory Criteria</p>
                </div>
                <div className={`px-4 py-2 rounded-full font-black text-xs uppercase tracking-widest ${scanResult.health_score > 70 ? 'bg-emerald-500 text-white' : 'bg-rose-500 text-white'}`}>
                  Score: {scanResult.health_score} / 100
                </div>
              </div>

              <div className="grid md:grid-cols-2 gap-8">
                <div className="space-y-4">
                  <h4 className="flex items-center gap-2 text-xs font-black uppercase tracking-widest text-slate-500">
                    <AlertTriangle size={14} className="text-amber-500" /> Key Violations
                  </h4>
                  <ul className="space-y-2">
                    {scanResult.violations.map((v, i) => (
                      <li key={i} className="bg-slate-50 text-slate-700 text-[10px] font-bold py-3 px-4 rounded-xl border-l-4 border-rose-500">
                        {v}
                      </li>
                    ))}
                    {scanResult.violations.length === 0 && <li className="text-emerald-600 italic text-sm">No violations detected in the provided context.</li>}
                  </ul>
                </div>

                <div className="space-y-4">
                  <h4 className="flex items-center gap-2 text-xs font-black uppercase tracking-widest text-slate-500">
                    <ShieldCheck size={14} className="text-emerald-500" /> Recommendations
                  </h4>
                  <ul className="space-y-2">
                    {scanResult.recommendations.map((r, i) => (
                      <li key={i} className="bg-white border border-slate-100 text-slate-600 text-[10px] font-bold py-3 px-4 rounded-xl shadow-sm">
                        {r}
                      </li>
                    ))}
                  </ul>
                </div>
              </div>
           </div>
        </div>
      )}
    </div>
  );
};

export default Compliance;
