import React from 'react';
import Compliance from './components/dashboard/Compliance';
import Providers from './components/dashboard/Providers';
import Shield from './components/dashboard/Shield';

function App() {
  const [activeTab, setActiveTab] = React.useState('Access Governance');

  const renderContent = () => {
    switch (activeTab) {
      case 'Access Governance': return <Shield />;
      case 'Consent Providers': return <Providers />;
      case 'Compliance': return <Compliance />;
      default: return <Shield />;
    }
  };

  return (
    <div className="min-h-screen bg-slate-50 font-sans text-slate-900">
      <nav className="bg-white border-b border-slate-200 px-8 py-4 sticky top-0 z-10 shadow-sm">
        <div className="max-w-6xl mx-auto flex justify-between items-center">
          <div className="flex items-center gap-2 cursor-pointer" onClick={() => setActiveTab('Access Governance')}>
            <div className="bg-slate-900 text-white p-2 rounded-lg font-black text-xl">P</div>
            <div>
              <span className="text-2xl font-black tracking-tighter block leading-none">PRISM</span>
              <span className="text-[10px] font-black uppercase tracking-widest text-slate-400">Enterprise Console</span>
            </div>
          </div>
          
          <div className="flex gap-7 text-sm font-bold text-slate-400">
            {['Access Governance', 'Consent Providers', 'Compliance'].map((tab) => (
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
             <div className="hidden lg:flex items-center gap-2 bg-slate-900 text-emerald-300 px-4 py-2 rounded-2xl border border-white/10 shadow-lg">
                <span className="text-xs font-black uppercase">Admin</span>
                <span className="text-sm font-black tracking-tight">Enterprise Shield</span>
             </div>
             
             <div className="flex items-center gap-3 bg-slate-100 p-1.5 rounded-full pr-4 border border-slate-200">
                <div className="w-7 h-7 rounded-full bg-blue-500 border border-white/20 shadow-inner"></div>
                <span className="text-[10px] font-black uppercase tracking-widest text-slate-500">ADMIN DEMO</span>
                <button 
                  onClick={() => localStorage.clear()}
                  className="ml-2 p-1 hover:text-rose-500 transition-colors"
                  title="Reset local demo state"
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
