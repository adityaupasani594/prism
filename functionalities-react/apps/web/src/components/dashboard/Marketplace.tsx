import React, { useState, useEffect } from 'react';
import { Coins, ShieldCheck, Info, ArrowRight, CheckCircle, Languages } from 'lucide-react';

interface DataRequest {
  id: string;
  requester_name: string;
  title: string;
  description: string;
  reward_amount: string;
}

interface MarketplaceResponse {
  status: string;
  payout_id: string;
  summary: string;
  reward_amount: string;
}

const Marketplace: React.FC = () => {
  const [requests, setRequests] = useState<DataRequest[]>([]);
  const [selectedRequest, setSelectedRequest] = useState<DataRequest | null>(null);
  const [aiSummary, setAiSummary] = useState<string>('');
  const [isProcessing, setIsProcessing] = useState(false);
  const [payoutResult, setPayoutResult] = useState<MarketplaceResponse | null>(null);

  useEffect(() => {
    fetchRequests();
  }, []);

  const fetchRequests = async () => {
    try {
      const response = await fetch('/api/v1/marketplace/requests');
      const data = await response.json();
      setRequests(data);
    } catch (err) {
      console.error('Failed to fetch marketplace requests');
    }
  };

  const handleConsentClick = async (request: DataRequest) => {
    setSelectedRequest(request);
    setIsProcessing(true);
    setAiSummary('');
    setPayoutResult(null);

    try {
        // Step 1: Request AI Summary & Process Consent
        const response = await fetch('/api/v1/marketplace/respond', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                user_did: "did:prism:user_123", // Matches Consents.tsx
                request_id: request.id
            })
        });
        
        const result = await response.json();
        setAiSummary(result.summary);
        setPayoutResult(result);
    } catch (err) {
        console.error('Error processing marketplace response');
    } finally {
        setIsProcessing(false);
    }
  };

  return (
    <div className="p-8 max-w-6xl mx-auto">
      <header className="mb-10">
        <h1 className="text-3xl font-bold text-slate-900 mb-2">Data Demand Marketplace</h1>
        <p className="text-slate-600">Monetize your data ethically with privacy-first consent.</p>
      </header>

      {/* Requests Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {requests.map((req) => (
          <div key={req.id} className="bg-white border border-slate-200 rounded-2xl p-6 shadow-sm hover:shadow-md transition-shadow">
            <div className="flex justify-between items-start mb-4">
              <div className="bg-blue-50 p-3 rounded-xl">
                <Coins className="text-blue-600 w-6 h-6" />
              </div>
              <span className="text-lg font-bold text-green-600">{req.reward_amount}</span>
            </div>
            <h3 className="text-xl font-semibold text-slate-900 mb-1">{req.title}</h3>
            <p className="text-sm text-slate-500 mb-4 font-medium">{req.requester_name}</p>
            <p className="text-slate-600 text-sm mb-6 line-clamp-3">{req.description}</p>
            
            <button 
              onClick={() => handleConsentClick(req)}
              className="w-full flex items-center justify-center gap-2 bg-slate-900 text-white py-3 rounded-xl font-semibold hover:bg-slate-800 transition-colors"
            >
              Consent & Earn <ArrowRight size={18} />
            </button>
          </div>
        ))}
      </div>

      {/* AI Summary & Payout Modal */}
      {selectedRequest && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-3xl max-w-2xl w-full max-h-[90vh] overflow-y-auto shadow-2xl">
            <div className="p-8">
              <div className="flex justify-between items-center mb-6">
                <div>
                  <h2 className="text-2xl font-bold text-slate-900">Privacy Review</h2>
                  <p className="text-slate-500">Intelligent Plain Language Notice by Gemini AI</p>
                </div>
                <button 
                  onClick={() => setSelectedRequest(null)}
                  className="text-slate-400 hover:text-slate-600"
                >
                  <ArrowRight className="rotate-180" />
                </button>
              </div>

              {isProcessing ? (
                <div className="flex flex-col items-center justify-center py-12">
                  <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600 mb-4"></div>
                  <p className="text-slate-600 animate-pulse">Gemini is analyzing the Privacy Policy...</p>
                </div>
              ) : (
                <div className="space-y-6">
                  {/* Summary Bullets */}
                  <div className="bg-slate-50 rounded-2xl p-6 border border-slate-100">
                    <div className="flex items-center gap-2 text-blue-600 mb-4 font-bold uppercase tracking-wider text-xs">
                      <Languages size={16} /> Plain Language Summary (English / Hindi)
                    </div>
                    <div className="prose prose-slate text-sm whitespace-pre-line text-slate-700 leading-relaxed font-medium">
                      {aiSummary}
                    </div>
                  </div>

                  {payoutResult && (
                    <div className="bg-green-50 border border-green-100 rounded-2xl p-6">
                      <div className="flex items-start gap-4">
                        <CheckCircle className="text-green-600 shrink-0 mt-1" size={24} />
                        <div>
                          <h4 className="font-bold text-green-900">Success! Payout Processed</h4>
                          <p className="text-green-700 text-sm mb-2">
                             Razorpay UPI Simulation: {payoutResult.reward_amount} transferred to your wallet.
                          </p>
                          <code className="bg-white bg-opacity-50 px-2 py-1 rounded text-xs text-green-800">
                            ID: {payoutResult.payout_id}
                          </code>
                        </div>
                      </div>
                    </div>
                  )}

                  {!payoutResult && (
                    <div className="flex gap-4 pt-4">
                      <button 
                        onClick={() => setSelectedRequest(null)}
                        className="flex-1 bg-slate-100 text-slate-700 font-bold py-4 rounded-2xl hover:bg-slate-200 transition-colors"
                      >
                        Decline
                      </button>
                      <button 
                        className="flex-1 bg-green-600 text-white font-bold py-4 rounded-2xl hover:bg-green-700 transition-colors flex items-center justify-center gap-2"
                      >
                        <ShieldCheck size={20} /> I Consent & Accept
                      </button>
                    </div>
                  )}
                  
                  {payoutResult && (
                    <button 
                      onClick={() => setSelectedRequest(null)}
                      className="w-full bg-slate-900 text-white font-bold py-4 rounded-2xl hover:bg-slate-800 transition-colors"
                    >
                      Done
                    </button>
                  )}
                </div>
              )}
            </div>
            
            <div className="bg-slate-50 p-4 text-center border-t border-slate-100">
              <p className="text-[10px] text-slate-400 uppercase tracking-widest font-bold flex items-center justify-center gap-1">
                <Info size={12} /> Powered by PRISM Consent Engine & Gemini 1.5 Flash
              </p>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};

export default Marketplace;
