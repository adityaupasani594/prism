/**
 * PRISM Circuit Compilation Script (Groth16)
 * This script automates the compilation of Circom circuits and the Groth16 trusted setup.
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const CIRCUIT_NAME = 'age_proof';
const BUILD_DIR = path.resolve(__dirname, '../build');
const PTAU_PATH = path.resolve(BUILD_DIR, 'powersOfTau28_hez_final_12.ptau');

const WEB_ZK_DIR = path.resolve(__dirname, '../../apps/web/public/zk');

function run(command) {
    console.log(`\x1b[36mRunning: ${command}\x1b[0m`);
    try {
        execSync(command, { stdio: 'inherit' });
    } catch (error) {
        console.error(`\x1b[31mError executing: ${command}\x1b[0m`);
        process.exit(1);
    }
}

async function main() {
    if (!fs.existsSync(BUILD_DIR)) {
        fs.mkdirSync(BUILD_DIR);
    }

    console.log('--- Starting Circuit Compilation (Groth16) ---');

    // 1. Compile Circuit
    run(`circom circuits/${CIRCUIT_NAME}.circom --r1cs --wasm --sym --output circuits/build`);

    // 2. Powers of Tau (Initial phase)
    // Check if PTAU exists and is of reasonable size (> 1MB)
    const ptauExists = fs.existsSync(PTAU_PATH);
    const ptauSize = ptauExists ? fs.statSync(PTAU_PATH).size : 0;

    if (!ptauExists || ptauSize < 1024 * 1024) {
        if (ptauExists) {
            console.log('\x1b[33mCorrupted PTAU found. Redownloading...\x1b[0m');
            fs.unlinkSync(PTAU_PATH);
        }
        console.log('\x1b[33mWarning: PTAU file not found or corrupted. In production, use a verified PTAU.\x1b[0m');
        console.log('Downloading a small PTAU (Power 10) for development bootstrap...');
        // Using the Google Cloud Storage mirror which is generally more reliable for direct downloads
        run(`curl -L https://storage.googleapis.com/zkevm/ptau/powersOfTau28_hez_final_10.ptau -o ${PTAU_PATH}`);
    }

    // 3. Setup Groth16 (Circuit Specific)
    run(`snarkjs groth16 setup circuits/build/${CIRCUIT_NAME}.r1cs ${PTAU_PATH} circuits/build/${CIRCUIT_NAME}_0000.zkey`);

    // 4. Contribute to phase 2 (Trusted Setup)
    run(`echo "random text" | snarkjs zkey contribute circuits/build/${CIRCUIT_NAME}_0000.zkey circuits/build/${CIRCUIT_NAME}_final.zkey --name="First Contribution" -v`);

    // 5. Export Verification Key
    run(`snarkjs zkey export verificationkey circuits/build/${CIRCUIT_NAME}_final.zkey circuits/build/verification_key.json`);

    // 6. Deploy to Frontend
    console.log('--- Deploying artifacts to Frontend ---');
    if (!fs.existsSync(WEB_ZK_DIR)) {
        fs.mkdirSync(WEB_ZK_DIR, { recursive: true });
    }
    
    fs.copyFileSync(path.join(BUILD_DIR, `${CIRCUIT_NAME}_js/${CIRCUIT_NAME}.wasm`), path.join(WEB_ZK_DIR, `${CIRCUIT_NAME}.wasm`));
    fs.copyFileSync(path.join(BUILD_DIR, `${CIRCUIT_NAME}_final.zkey`), path.join(WEB_ZK_DIR, `${CIRCUIT_NAME}_final.zkey`));
    fs.copyFileSync(path.join(BUILD_DIR, 'verification_key.json'), path.join(WEB_ZK_DIR, 'verification_key.json'));

    console.log('\x1b[32m--- Compilation & Deployment Complete ---\x1b[0m');
    console.log(`Artifacts deployed to: ${WEB_ZK_DIR}`);
}

main();
