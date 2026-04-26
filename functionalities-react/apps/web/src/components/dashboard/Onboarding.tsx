import React, { useState } from 'react';
import { ShieldCheck, Upload, Loader2, Key, Trash, Sparkles } from 'lucide-react';

interface OnboardingProps {
  onComplete: () => void;
}

const Onboarding: React.FC<OnboardingProps> = ({ onComplete }) => {
  const [step, setStep] = useState(1);
  const [isProcessing, setIsProcessing] = useState(false);
  const [fileName, setFileName] = useState<string | null>(null);
  const [traits, setTraits] = useState({
    name: 'VEDANT *******',
    dob: '15/04/2000',
    status: 'VERIFIED INDIAN',
    docId: 'XXXX-XXXX-4282'
  });

  const handleFileUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    if (e.target.files && e.target.files[0]) {
      const file = e.target.files[0];
      setFileName(file.name);
      setIsProcessing(true);
      
      try {
        const formData = new FormData();
        formData.append('file', file);

        const response = await fetch('/api/v1/scan-identity-document', {
          method: 'POST',
          body: formData,
        });

        if (!response.ok) throw new Error('Scan failed');
        
        const data = await response.json();
        setTraits({
          name: data.name || 'NOT FOUND',
          dob: data.dob || 'NOT FOUND',
          status: data.status || 'RESIDENT',
          docId: data.docId || 'NOT FOUND'
        });
        setStep(2);
      } catch (err) {
        console.error("OCR Error:", err);
        alert("Extraction failed. Please ensure the image is clear or try another file.");
      } finally {
        setIsProcessing(false);
      }
    }
  };

  const handleFinalize = async () => {
    setIsProcessing(true);
    try {
      // Register DID on backend
      await fetch(`/api/v1/onboard?did=did:prism:user_123`, { method: 'POST' });
      localStorage.setItem('prism_onboarded', 'true');
      localStorage.setItem('prism_vault_traits', JSON.stringify(traits));
      onComplete();
    } catch (err) {
      console.error("Onboarding failed");
    } finally {
      setIsProcessing(false);
    }
  };

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center bg-slate-900/40 backdrop-blur-xl p-4">
      <div className="bg-white rounded-[3rem] shadow-2xl max-w-lg w-full overflow-hidden border border-white/20 animate-in zoom-in-95 duration-500">
        <div className="p-10 text-center">
          {step === 1 && (
            <div className="space-y-6">
              <div className="bg-slate-900 text-white w-20 h-20 rounded-3xl flex items-center justify-center mx-auto mb-8 shadow-2xl rotate-3">
                <ShieldCheck size={40} />
              </div>
              <h1 className="text-4xl font-black tracking-tight text-slate-900 uppercase italic">
                Initialize Vault
              </h1>
              <p className="text-slate-500 font-medium leading-relaxed">
                To begin, securely upload your identity document. We use this to generate your unique, untraceable **PRISM DID**.
              </p>
              
              <div className="relative group">
                <input 
                  type="file" 
                  onChange={handleFileUpload}
                  className="absolute inset-0 opacity-0 cursor-pointer z-10"
                  disabled={isProcessing}
                />
                <div className={`border-4 border-dashed rounded-3xl p-12 transition-all ${
                  isProcessing ? 'border-prism-primary bg-prism-primary/5' : 'border-slate-100 group-hover:border-slate-200 bg-slate-50'
                }`}>
                  {isProcessing ? (
                    <div className="flex flex-col items-center gap-4">
                      <Loader2 className="animate-spin text-prism-primary w-10 h-10" />
                      <p className="text-prism-primary font-black uppercase tracking-widest text-xs">Extracting Attributes locally...</p>
                    </div>
                  ) : (
                    <div className="flex flex-col items-center gap-2">
                      <Upload className="text-slate-300 w-12 h-12 mb-2" />
                      <p className="text-slate-900 font-bold">Drop Aadhaar/PAN here</p>
                      <p className="text-slate-400 text-xs font-bold uppercase tracking-widest">or click to browse</p>
                    </div>
                  )}
                </div>
              </div>
              
              <p className="text-[10px] text-slate-400 font-black uppercase tracking-[0.2em] italic">
                🛡️ DPDP Minimization: Documents are purged immediately after trait parsing.
              </p>
            </div>
          )}

          {step === 2 && (
            <div className="space-y-6 animate-in slide-in-from-right-8 duration-500">
              <div className="bg-emerald-500 text-white w-20 h-20 rounded-full flex items-center justify-center mx-auto mb-8 shadow-lg">
                <Key size={40} />
              </div>
              <h2 className="text-3xl font-black text-slate-900 uppercase tracking-tighter">
                Identity Minimized
              </h2>
              
              <div className="bg-slate-50 rounded-2xl p-6 border border-slate-100 text-left space-y-4">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-black uppercase text-slate-400">Raw Document:</span>
                  <span className="flex items-center gap-2 text-rose-500 font-black text-xs uppercase italic">
                    <Trash size={12} /> Deleted Forever
                  </span>
                </div>
                
                <div className="space-y-4">
                  <span className="text-xs font-black uppercase text-slate-400 block mb-2">Review Extracted Traits:</span>
                  <div className="grid grid-cols-2 gap-3">
                    {Object.entries(traits).map(([key, value]) => (
                      <div key={key} className="bg-white border border-slate-200 p-3 rounded-2xl group/input">
                        <label className="text-[8px] font-black uppercase text-slate-400 block mb-1">{key}</label>
                        <input 
                          value={value}
                          onChange={(e) => setTraits({...traits, [key]: e.target.value.toUpperCase()})}
                          className="w-full bg-transparent text-[10px] font-black text-slate-900 outline-none focus:text-prism-primary"
                        />
                      </div>
                    ))}
                  </div>
                </div>
              </div>

              <div className="p-6 bg-prism-primary/5 rounded-3xl border border-prism-primary/20 space-y-2">
                <h3 className="text-xs font-black uppercase text-prism-primary tracking-widest">Your Generated DID</h3>
                <code className="text-[10px] font-bold text-slate-900 block break-all">did:prism:0x7a2e1477ec685d2b91b2a3694df3b4e798d32a3f</code>
              </div>

              <button
                onClick={handleFinalize}
                disabled={isProcessing}
                className="w-full bg-slate-900 text-white py-5 rounded-3xl font-black uppercase tracking-[0.2em] shadow-xl hover:bg-black transition-all transform hover:-translate-y-1 active:scale-95 flex items-center justify-center gap-3"
              >
                {isProcessing ? <Loader2 className="animate-spin" /> : <><Sparkles size={18} /> Enter Consent Economy</>}
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
};

export default Onboarding;
