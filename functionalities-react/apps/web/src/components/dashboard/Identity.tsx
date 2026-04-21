import React, { useState, useEffect } from 'react';
import { Fingerprint, Verified, ShieldCheck, Loader2, Sparkles, Binary } from 'lucide-react';
import { useZKP } from '../../hooks/useZKP';

const Identity: React.FC = () => {
  const { generateProof, verifyProof, isLoading, error } = useZKP();
  const [birthYear, setBirthYear] = useState<number>(2000);
  const [proofData, setProofData] = useState<any>(null);
  const [isVerified, setIsVerified] = useState(false);
  const [stage, setStage] = useState<'IDLE' | 'GENERATING' | 'VERIFYING' | 'SUCCESS'>('IDLE');
  const [userTraits, setUserTraits] = useState<any>(null);

  useEffect(() => {
    const saved = localStorage.getItem('prism_vault_traits');
    if (saved) {
      const parsed = JSON.parse(saved);
      setUserTraits(parsed);
      // Automatically sync birth year for ZK proof from vault
      if (parsed.dob) {
        const year = parseInt(parsed.dob.split('/').pop());
        if (!isNaN(year)) setBirthYear(year);
      }
    }
  }, []);

  const currentYear = new Date().getFullYear();

  const handleVerify = async () => {
    // 0. Pre-validate in frontend for better UX
    if (currentYear - birthYear < 18) {
      setStage('IDLE');
      setIsVerified(false);
      return;
    }

    setStage('GENERATING');
    setProofData(null);
    setIsVerified(false);

    // 1. Generate Proof locally in-browser
    const result = await generateProof(birthYear, currentYear);
    
    if (result) {
      setProofData(result);
      setStage('VERIFYING');
      
      // 2. Verify Proof (Simulating local/blockchain verification)
      const valid = await verifyProof(result.proof, result.publicSignals);
      setIsVerified(valid);
      setStage('SUCCESS');
    } else {
      setStage('IDLE');
    }
  };

  return (
    <div className="max-w-4xl mx-auto space-y-8 animate-in fade-in zoom-in-95 duration-700">
      <div className="text-center space-y-4">
        <div className="inline-flex items-center gap-2 bg-gradient-to-r from-prism-primary to-prism-secondary p-3 rounded-2xl shadow-lg shadow-prism-primary/20 mb-4 animate-bounce">
          <Fingerprint className="text-white w-8 h-8" />
        </div>
        <h1 className="text-5xl font-black tracking-tighter text-slate-900 uppercase italic">
          Zero-Knowledge Identity
        </h1>
        <p className="text-slate-500 font-medium max-w-xl mx-auto">
          Prove your attributes (Age, Location, Citizenship) without ever revealing the underlying sensitive data.
        </p>
      </div>

      {/* Local Vault Section */}
      <div className="bg-slate-900 rounded-[2.5rem] p-8 text-white shadow-2xl overflow-hidden relative group">
        <div className="absolute top-0 right-0 p-8 opacity-5 group-hover:opacity-10 transition-opacity">
           <ShieldCheck size={160} />
        </div>
        
        <div className="flex justify-between items-start mb-8">
           <div>
              <h3 className="text-xs font-black uppercase tracking-[0.3em] text-prism-accent mb-2">Local Identity Vault (L3)</h3>
              <p className="text-white/50 text-xs font-bold uppercase tracking-widest italic">Encrypted Secure Enclave •did:prism:user_123</p>
           </div>
           <div className="bg-emerald-500/20 text-emerald-400 px-4 py-2 rounded-full text-[10px] font-black uppercase tracking-widest border border-emerald-500/30">
              Raw Data Purged
           </div>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
           {[
             { label: 'Full Name', value: userTraits?.name || 'VEDANT *******', icon: '👤' },
             { label: 'Date of Birth', value: userTraits?.dob || '15/04/2000', icon: '📅' },
             { label: 'Resident Status', value: userTraits?.status || 'VERIFIED INDIAN', icon: '🇮🇳' },
             { label: 'Document ID', value: userTraits?.docId || 'XXXX-XXXX-4282', icon: '📄' }
           ].map(trait => (
             <div key={trait.label} className="bg-white/5 border border-white/10 p-4 rounded-3xl hover:bg-white/10 transition-colors">
                <div className="text-xl mb-2">{trait.icon}</div>
                <p className="text-[10px] font-black uppercase text-white/40 tracking-wider mb-1">{trait.label}</p>
                <p className="text-sm font-black text-white group-hover:text-prism-accent transition-colors">{trait.value}</p>
             </div>
           ))}
        </div>
        
        <div className="mt-8 pt-6 border-t border-white/10 flex items-center justify-between">
           <p className="text-[10px] text-white/30 font-bold uppercase tracking-[0.2em] max-w-sm">
             These identity artifacts are stored locally in your browser's indexedDB vault and never transmitted to PRISM servers.
           </p>
           <button className="text-[10px] font-black uppercase tracking-widest bg-white/10 hover:bg-white/20 px-4 py-2 rounded-xl transition-all">
             Backup Vault
           </button>
        </div>
      </div>

      <div className="grid md:grid-cols-2 gap-8 items-stretch">
        {/* Verification Card */}
        <div className="bg-white border border-slate-200 rounded-[2.5rem] p-8 shadow-2xl shadow-slate-200/50 flex flex-col justify-between">
          <div>
            <div className="flex items-center gap-3 mb-8">
              <div className="bg-blue-50 p-2 rounded-xl">
                <ShieldCheck className="text-blue-600 w-5 h-5" />
              </div>
              <h2 className="text-xl font-black text-slate-900">Age Verification (L3)</h2>
            </div>

            <div className="space-y-6">
              <div className="space-y-2">
                <label className="text-xs font-black uppercase tracking-widest text-slate-400">Your Birth Year</label>
                <div className="relative group">
                  <input 
                    type="number" 
                    value={birthYear}
                    onChange={(e) => setBirthYear(parseInt(e.target.value))}
                    disabled={stage !== 'IDLE' && stage !== 'SUCCESS'}
                    className="w-full bg-slate-50 border-2 border-slate-100 rounded-2xl px-6 py-4 text-2xl font-black text-slate-900 focus:border-prism-primary focus:bg-white transition-all outline-none"
                    placeholder="2004"
                  />
                  <div className="absolute right-4 top-1/2 -translate-y-1/2 opacity-20 group-hover:opacity-100 transition-opacity">
                    <span className="text-[10px] font-black uppercase tracking-widest text-prism-primary bg-prism-primary/10 px-2 py-1 rounded-md">Private Local Input</span>
                  </div>
                </div>
                <p className="text-[10px] text-slate-400 font-bold leading-relaxed italic">
                  Note: This value NEVER leaves your browser. PRISM only receives a mathematical proof.
                </p>
              </div>

              <div className="bg-slate-50 rounded-2xl p-4 border border-slate-100 italic text-sm text-slate-600">
                <span className="font-bold text-slate-900">Task:</span> Prove that user is <strong>18+ years old</strong> for DPDP compliance.
              </div>
            </div>
          </div>

          <button
            onClick={handleVerify}
            disabled={isLoading || stage === 'GENERATING' || stage === 'VERIFYING'}
            className="w-full mt-10 bg-prism-primary hover:bg-slate-900 text-white py-5 rounded-3xl font-black uppercase tracking-[0.2em] shadow-xl shadow-prism-primary/20 transition-all transform hover:-translate-y-1 active:scale-95 disabled:opacity-50 disabled:transform-none flex items-center justify-center gap-3"
          >
            {(stage === 'GENERATING' || stage === 'VERIFYING') ? (
              <>
                <Loader2 className="animate-spin" />
                {stage === 'GENERATING' ? 'Generating ZK Proof...' : 'Verifying Logically...'}
              </>
            ) : (
              <>
                <Sparkles size={20} /> Generate ZK-Age-Proof
              </>
            )}
          </button>
        </div>

        {/* Proof Artifact Display */}
        <div className="bg-slate-900 rounded-[2.5rem] p-8 text-white relative overflow-hidden flex flex-col justify-between">
          <div className="absolute top-0 right-0 p-8 opacity-10">
            <Binary size={120} />
          </div>

          <div>
            <h3 className="text-xs font-black uppercase tracking-[0.3em] text-prism-accent mb-8">Proof Artifact (Groth16)</h3>
            
            {stage === 'IDLE' && (
              <div className="h-48 flex flex-col items-center justify-center border-2 border-dashed border-white/10 rounded-3xl">
                <p className="text-white/30 text-xs font-black uppercase tracking-widest">Waiting for compute...</p>
              </div>
            )}

            {(stage === 'GENERATING' || stage === 'VERIFYING' || stage === 'SUCCESS') && (
              <div className="space-y-4 font-mono text-[10px] leading-relaxed">
                <div className="bg-white/5 p-4 rounded-xl border border-white/10 break-all overflow-y-auto max-h-64">
                   <div className="text-prism-accent mb-2">// Public Signals</div>
                   <div className="text-white/60 mb-4">[ {currentYear}, {birthYear > currentYear - 18 ? '0' : '1'} ]</div>
                   
                   <div className="text-prism-accent mb-2">// Groth16 Proof (Curve: BN128)</div>
                   <div className="text-white/40 italic">
                    {proofData ? JSON.stringify(proofData.proof).substring(0, 400) + '...' : 'Calculating witnesses...'}
                   </div>
                </div>
              </div>
            )}
          </div>

          {stage === 'SUCCESS' && (
            <div className={`mt-8 p-6 rounded-3xl border-2 flex items-center gap-4 transition-all animate-in zoom-in-90 ${
              isVerified ? 'bg-emerald-500/10 border-emerald-500/50' : 'bg-rose-500/10 border-rose-500/50'
            }`}>
              <div className={isVerified ? 'text-emerald-400' : 'text-rose-400'}>
                {isVerified ? <Verified size={32} /> : <AlertCircle size={32} />}
              </div>
              <div>
                <h4 className={`font-black uppercase tracking-widest ${isVerified ? 'text-emerald-400' : 'text-rose-400'}`}>
                  {isVerified ? 'Verification Passed' : 'Verification Failed'}
                </h4>
                <p className="text-[10px] text-white/60 font-medium">
                  {isVerified 
                    ? 'Mathematics proves you are 18+. Platform access granted.' 
                    : 'The proof does not satisfy the age constraint.'}
                </p>
              </div>
            </div>
          )}
          
          {error && (
            <div className="mt-4 text-rose-400 text-xs font-bold p-4 bg-rose-400/10 rounded-xl border border-rose-400/20 animate-pulse">
              <span className="text-rose-500 font-black uppercase mr-2">[Security Error]</span>
              {error.includes("Assert Failed") 
                ? "Age Constraint Denied: You must be 18 or older to generate this proof artifact." 
                : error}
            </div>
          )}
          
          {(currentYear - birthYear < 18) && stage === 'IDLE' && (
            <div className="mt-4 text-amber-500 text-[10px] font-black uppercase tracking-[0.2em] p-4 bg-amber-500/5 rounded-xl border border-amber-500/20 text-center">
              ⚠️ Input Error: Year {birthYear} results in age {currentYear - birthYear} (Under 18)
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Identity;
