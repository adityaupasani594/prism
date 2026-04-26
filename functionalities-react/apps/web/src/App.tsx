import React from 'react';
import Marketplace from './components/dashboard/Marketplace';
import Consents from './components/dashboard/Consents';
import Identity from './components/dashboard/Identity';
import Compliance from './components/dashboard/Compliance';
import Onboarding from './components/dashboard/Onboarding';

function App() {
  const [activeTab, setActiveTab] = React.useState('Marketplace');
  const [hasOnboarded, setHasOnboarded] = React.useState(() => localStorage.getItem('prism_onboarded') === 'true');
  const [walletBalance, setWalletBalance] = React.useState("0");
  const userDid = "did:prism:user_123";

  React.useEffect(() => {
    if (hasOnboarded) {
      fetchWallet();
      // Poll wallet every 10s for updates after marketplace grants
      const interval = setInterval(fetchWallet, 10000);
      return () => clearInterval(interval);
    }
  }, [hasOnboarded]);

  const fetchWallet = async () => {
    try {
      const response = await fetch(`/api/v1/wallet/status?did=${userDid}`);
      const data = await response.json();
      setWalletBalance(data.token_balance);
    } catch (err) {
      console.error("Wallet fetch error");
    }
  };

  const renderContent = () => {
    switch (activeTab) {
      case 'Marketplace': return <Marketplace />;
      case 'Consents': return <Consents />;
      case 'Identity': return <Identity />;
      case 'Compliance': return <Compliance />;
      default: return <Marketplace />;
    }
  };

  if (!hasOnboarded) {
    return <Onboarding onComplete={() => setHasOnboarded(true)} />;
  }

  return (
    <div className="min-h-screen bg-slate-50 font-sans text-slate-900">
      <nav className="bg-white border-b border-slate-200 px-8 py-4 sticky top-0 z-10 shadow-sm">
        <div className="max-w-6xl mx-auto flex justify-between items-center">
          <div className="flex items-center gap-2 cursor-pointer" onClick={() => setActiveTab('Marketplace')}>
            <div className="bg-slate-900 text-white p-2 rounded-lg font-black text-xl">P</div>
            <span className="text-2xl font-black tracking-tighter">PRISM</span>
          </div>
          
          <div className="flex gap-8 text-sm font-bold text-slate-400">
            {['Marketplace', 'Consents', 'Identity', 'Compliance'].map((tab) => (
              <button
                key={tab}
                onClick={() => setActiveTab(tab)}
                className={`transition-all pb-1 border-b-2 ${
                  activeTab === tab 
                    ? 'text-slate-900 border-prism-primary' 
                    : 'border-transparent hover:text-slate-600'
                }`}
              >
                {tab}
              </button>
            ))}
          </div>

          <div className="flex items-center gap-4">
             <div className="flex items-center gap-2 bg-slate-900 text-amber-400 px-4 py-2 rounded-2xl border border-white/10 shadow-lg">
                <span className="text-xs font-black uppercase">Tokens</span>
                <span className="text-sm font-black tracking-tight">🪙 {parseInt(walletBalance).toLocaleString()}</span>
             </div>
             
             <div className="flex items-center gap-3 bg-slate-100 p-1.5 rounded-full pr-4 border border-slate-200">
                <div className="w-7 h-7 rounded-full bg-blue-500 border border-white/20 shadow-inner"></div>
                <span className="text-[10px] font-black uppercase tracking-widest text-slate-500">USER_123</span>
                <button 
                  onClick={() => { localStorage.clear(); window.location.reload(); }}
                  className="ml-2 p-1 hover:text-rose-500 transition-colors"
                  title="Reset Onboarding Data"
                >
                  <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><path d="M3 12a9 9 0 1 0 9-9 9.75 9.75 0 0 0-6.74 2.74L3 8"/><path d="M3 3v5h5"/></svg>
                </button>
             </div>
          </div>
        </div>
      </nav>

      <main className="max-w-6xl mx-auto py-8 px-8 min-h-[70vh]">
        {renderContent()}
      </main>
    </div>
  );
}

export default App;
