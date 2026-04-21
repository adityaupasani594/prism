import { useState } from 'react';

/**
 * useZKP Hook
 * Integrates SnarkJS for Zero-Knowledge Proof generation and verification in the browser.
 * 
 * Note: .wasm and .zkey files must be placed in the public/zk/ directory of the web app.
 */
export const useZKP = () => {
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Constants for ZK artifacts
  const WASM_PATH = '/zk/age_proof.wasm';
  const ZKEY_PATH = '/zk/age_proof_final.zkey';
  const VKEY_PATH = '/zk/verification_key.json';

  /**
   * Generates a Groth16 proof for age verification.
   * @param birthYear Private input (user's birth year)
   * @param currentYear Public input (the year against which to prove)
   */
  const generateProof = async (birthYear: number, currentYear: number) => {
    setIsLoading(true);
    setError(null);
    try {
      // Dynamic import to avoid SSR issues if used in Next.js/etc.
      // @ts-ignore
      const snarkjs = await import('snarkjs');

      const { proof, publicSignals } = await snarkjs.groth16.fullProve(
        { birthYear, currentYear },
        WASM_PATH,
        ZKEY_PATH
      );

      return { proof, publicSignals };
    } catch (err: any) {
      console.error('ZKP Generation Error:', err);
      setError(err.message || 'Failed to generate ZK proof');
      return null;
    } finally {
      setIsLoading(false);
    }
  };

  /**
   * Verifies a generated proof locally.
   * @param proof The generated proof object
   * @param publicSignals The public signals (outputs/public inputs)
   */
  const verifyProof = async (proof: any, publicSignals: any) => {
    try {
      // @ts-ignore
      const snarkjs = await import('snarkjs');
      
      const response = await fetch(VKEY_PATH);
      const vKey = await response.json();

      const isValid = await snarkjs.groth16.verify(vKey, publicSignals, proof);
      return isValid;
    } catch (err) {
      console.error('ZKP Verification Error:', err);
      return false;
    }
  };

  return {
    generateProof,
    verifyProof,
    isLoading,
    error
  };
};
