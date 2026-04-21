pragma circom 2.1.4;

/*
    Age Proof Circuit
    Proves: (currentYear - birthYear) >= 18
    Public Inputs: currentYear
    Private Inputs: birthYear
*/

// Using a standard comparison template logic
template GreaterEqualThan(n) {
    signal input in[2];
    signal output out;

    component lt = LessThan(n);

    lt.in[0] <== in[0];
    lt.in[1] <== in[1];

    out <== 1 - lt.out;
}

template LessThan(n) {
    assert(n <= 252);
    signal input in[2];
    signal output out;

    component n2b = Num2Bits(n+1);

    n2b.in <== in[0] + (1 << n) - in[1];

    out <== 1 - n2b.out[n];
}

template Num2Bits(n) {
    signal input in;
    signal output out[n];
    var lc1=0;

    for (var i = 0; i<n; i++) {
        out[i] <-- (in >> i) & 1;
        out[i] * (out[i] - 1) === 0;
        lc1 += out[i] * 2**i;
    }

    lc1 === in;
}

template AgeProof() {
    // Private input: the user's secret birth year
    signal input birthYear;
    
    // Public input: the year of verification
    signal input currentYear;

    // Intermediate signal: calculate age
    // Note: We use 32 bits for year range (sufficient)
    signal age;
    age <== currentYear - birthYear;

    // Check age >= 18
    component geq = GreaterEqualThan(32);
    geq.in[0] <== age;
    geq.in[1] <== 18;

    // Constraint: out must be 1 (true)
    geq.out === 1;
}

component main { public [ currentYear ] } = AgeProof();
