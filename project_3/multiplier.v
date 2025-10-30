`timescale 1ns/1ps

module multiplier(
    input [3:0] A,      // 4-bit multiplicand
    input [3:0] B,      // 4-bit multiplier  
    output [7:0] product // 8-bit product
);

    // Internal wires for partial products
    wire [3:0] pp0, pp1, pp2, pp3; // partial products
    
    // Internal wires for carry and sum connections
    wire c1_0, c1_1, c1_2, c1_3;  // carry outputs from first row
    wire c2_0, c2_1, c2_2, c2_3;  // carry outputs from second row
    wire c3_0, c3_1, c3_2, c3_3;  // carry outputs from third row
    wire s1_0, s1_1, s1_2;        // sum outputs from first row
    wire s2_0, s2_1, s2_2;        // sum outputs from second row
    
    // Generate partial products using AND gates
    // pp0 = A & B[0]
    assign pp0[0] = A[0] & B[0];
    assign pp0[1] = A[1] & B[0];
    assign pp0[2] = A[2] & B[0];
    assign pp0[3] = A[3] & B[0];
    
    // pp1 = A & B[1]
    assign pp1[0] = A[0] & B[1];
    assign pp1[1] = A[1] & B[1];
    assign pp1[2] = A[2] & B[1];
    assign pp1[3] = A[3] & B[1];
    
    // pp2 = A & B[2]
    assign pp2[0] = A[0] & B[2];
    assign pp2[1] = A[1] & B[2];
    assign pp2[2] = A[2] & B[2];
    assign pp2[3] = A[3] & B[2];
    
    // pp3 = A & B[3]
    assign pp3[0] = A[0] & B[3];
    assign pp3[1] = A[1] & B[3];
    assign pp3[2] = A[2] & B[3];
    assign pp3[3] = A[3] & B[3];
    
    // First output bit
    assign product[0] = pp0[0];
    
    // First row of adders (add pp0 and pp1)
    half_adder ha1(pp0[1], pp1[0], product[1], c1_0);
    full_adder fa1(pp0[2], pp1[1], c1_0, s1_0, c1_1);
    full_adder fa2(pp0[3], pp1[2], c1_1, s1_1, c1_2);
    half_adder ha2(pp1[3], c1_2, s1_2, c1_3);  // c1_3 is separate output
    
    // Second row of adders (add previous sum with pp2)
    half_adder ha3(s1_0, pp2[0], product[2], c2_0);
    full_adder fa3(s1_1, pp2[1], c2_0, s2_0, c2_1);
    full_adder fa4(s1_2, pp2[2], c2_1, s2_1, c2_2);
    full_adder fa5(c1_3, pp2[3], c2_2, s2_2, c2_3);  // c1_3 as input, c2_3 as output
    
    // Third row of adders (add previous sum with pp3)
    half_adder ha4(s2_0, pp3[0], product[3], c3_0);
    full_adder fa6(s2_1, pp3[1], c3_0, product[4], c3_1);
    full_adder fa7(s2_2, pp3[2], c3_1, product[5], c3_2);
    full_adder fa8(c2_3, pp3[3], c3_2, product[6], product[7]);  // c2_3 as input

endmodule

// Half adder module
module half_adder(
    input a,
    input b,
    output sum,
    output cout
);
    assign sum = a ^ b;
    assign cout = a & b;
endmodule

// Full adder module  
module full_adder(
    input a,
    input b,
    input cin,
    output sum,
    output cout
);
    assign sum = a ^ b ^ cin;
    assign cout = (a & b) | (cin & (a ^ b));
endmodule