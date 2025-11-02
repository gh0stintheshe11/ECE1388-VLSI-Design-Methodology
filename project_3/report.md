
### Q1.1 Verilog code ```multiplier.v```

```verilog
`timescale 1ns/1ps

module multiplier(
    input [3:0] A,      // 4-bit multiplicand
    input [3:0] B,      // 4-bit multiplier  
    output [7:0] product // 8-bit product
);

    // wires for partial products
    wire [3:0] pp0, pp1, pp2, pp3; // partial products

    // wires for carry and sum connections
    wire c1_0, c1_1, c1_2, c1_3;  // carry from first row
    wire c2_0, c2_1, c2_2, c2_3;  // carry from second row
    wire c3_0, c3_1, c3_2, c3_3;  // carry from third row
    wire s1_0, s1_1, s1_2;        // sum from first row
    wire s2_0, s2_1, s2_2;        // sum from second row

    // partial products using AND gates
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
    
    // first row of adders (add pp0 and pp1)
    half_adder ha1(pp0[1], pp1[0], product[1], c1_0);
    full_adder fa1(pp0[2], pp1[1], c1_0, s1_0, c1_1);
    full_adder fa2(pp0[3], pp1[2], c1_1, s1_1, c1_2);
    half_adder ha2(pp1[3], c1_2, s1_2, c1_3);  // c1_3 is separate output

    // second row of adders (add previous sum with pp2)
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
```

### Q1.2 verilog code simulation

```bash
ug253:~/ece1388/pj3% ncverilog testbench.v multiplier.v
ncverilog(64): 15.20-s079: (c) Copyright 1995-2019 Cadence Design Systems, Inc.
file: multiplier.v
	module worklib.multiplier:v
		errors: 0, warnings: 0
	module worklib.half_adder:v
		errors: 0, warnings: 0
	module worklib.full_adder:v
		errors: 0, warnings: 0
		Caching library 'worklib' ....... Done
	Elaborating the design hierarchy:
	Building instance overlay tables: .................... Done
	Generating native compiled code:
		worklib.full_adder:v <0x190a51b7>
			streams:   0, words:     0
		worklib.half_adder:v <0x43b4bc6c>
			streams:   0, words:     0
		worklib.multiplier:v <0x1db3a5d0>
			streams:   4, words:  1001
	Building instance specific data structures.
	Loading native compiled code:     .................... Done
	Design hierarchy summary:
		                 Instances  Unique
		Modules:                14       4
		Registers:               5       5
		Scalar wires:           41       -
		Vectored wires:          2       -
		Initial blocks:          1       1
		Cont. assignments:       4      21
		Simulation timescale:  1ps
	Writing initial simulation snapshot: worklib.testbench:v
Loading snapshot worklib.testbench:v .................... Done
ncsim> source /CMC/tools/cadence/INCISIVE15.20.079_lnx86/tools/inca/files/ncsimrc
ncsim> run
Test Completed without Errors! :)
ncsim: *W,RNQUIE: Simulation is complete.
ncsim> exit
```

### Q2.1 Synthesized schematic

- synthesis

![Synthesis](/project_3/synthesis.png)

- exported synthesized schematic

    *this is a high resolution image, please zoom in for details*

![Synthesized Schematic](/project_3/schematic.jpg)

### Q2.2

- timing report
  
```txt
 
****************************************
Report : timing
        -path full
        -delay max
        -max_paths 1
Design : multiplier
Version: N-2017.09
Date   : Thu Oct 30 15:35:33 2025
****************************************

Operating Conditions: WCCOM   Library: tcbn65gpluswc
Wire Load Model Mode: segmented

  Startpoint: A[0] (input port)
  Endpoint: product[6] (output port)
  Path Group: (none)
  Path Type: max

  Des/Clust/Port     Wire Load Model       Library
  ------------------------------------------------
  multiplier         ZeroWireload          tcbn65gpluswc

  Point                                    Incr       Path
  -----------------------------------------------------------
  input external delay                     0.00       0.00 f
  A[0] (in)                                0.00       0.00 f
  U43/Z (CKAN2D0)                          0.06       0.06 f
  U47/ZN (OAI21D0)                         0.06       0.13 r
  U54/S (FA1D0)                            0.17       0.29 f
  U64/CO (FA1D0)                           0.16       0.45 f
  U66/CO (FA1D0)                           0.17       0.62 f
  U59/ZN (INVD0)                           0.03       0.65 r
  U62/ZN (MUX2ND0)                         0.04       0.69 f
  U72/CO (FA1D0)                           0.17       0.86 f
  U82/ZN (XNR3D0)                          0.17       1.04 r
  product[6] (out)                         0.00       1.04 r
  data arrival time                                   1.04
  -----------------------------------------------------------
  (Path is unconstrained)
  

1
```

- area report

```txt
 
****************************************
Report : area
Design : multiplier
Version: N-2017.09
Date   : Thu Oct 30 15:35:33 2025
****************************************

Library(s) Used:

    tcbn65gpluswc (File: /CMC/kits/tsmc_65nm_libs/tcbn65gplus/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn65gplus_140b/tcbn65gpluswc.db)

Number of ports:                           16
Number of nets:                            53
Number of cells:                           40
Number of combinational cells:             40
Number of sequential cells:                 0
Number of macros/black boxes:               0
Number of buf/inv:                          8
Number of references:                      16

Combinational area:                113.400002
Buf/Inv area:                        8.640000
Noncombinational area:               0.000000
Macro/Black Box area:                0.000000
Net Interconnect area:      undefined  (Wire load has zero net area)

Total cell area:                   113.400002
Total area:                 undefined
1
```

### Q2.3 post synthesis simulation

```bash
ug253:~/ece1388/pj3% ncverilog testbench.v multiplier_syn.v tcbn65gplus.v
ncverilog(64): 15.20-s079: (c) Copyright 1995-2019 Cadence Design Systems, Inc.
file: multiplier_syn.v
	module worklib.multiplier:v
		errors: 0, warnings: 0
		Caching library 'worklib' ....... Done
	Elaborating the design hierarchy:
	Building instance overlay tables: .................... Done
	Generating native compiled code:
		worklib.AOI211D0:v <0x382b1ef2>
			streams:   0, words:     0
		worklib.AOI32D0:v <0x5f46efff>
			streams:   0, words:     0
		worklib.CKXOR2D1:v <0x7d6b8363>
			streams:   0, words:     0
		worklib.IAO21D0:v <0x3b8d7987>
			streams:   0, words:     0
		worklib.MUX2ND0:v <0x27bb68b9>
			streams:   0, words:     0
		worklib.OAI211D0:v <0x025666d1>
			streams:   0, words:     0
		worklib.OAI21D0:v <0x5f5403b9>
			streams:   0, words:     0
		worklib.XNR3D0:v <0x66ef4379>
			streams:   0, words:     0
	Building instance specific data structures.
	Loading native compiled code:     .................... Done
	Design hierarchy summary:
		                  Instances  Unique
		Modules:                870     846
		UDPs:                  1394       4
		Primitives:            3658      10
		Timing outputs:          56      29
		Registers:              353     355
		Scalar wires:           361       -
		Expanded wires:           8       2
		Always blocks:           56      56
		Initial blocks:           1       1
		Timing checks:         4170       -
		Simulation timescale:   1ps
	Writing initial simulation snapshot: worklib.testbench:v
Loading snapshot worklib.testbench:v .................... Done
ncsim> source /CMC/tools/cadence/INCISIVE15.20.079_lnx86/tools/inca/files/ncsimrc
ncsim> run
Test Completed without Errors! :)
ncsim: *W,RNQUIE: Simulation is complete.
ncsim> exit
```

### Q3.9 

- power analysis from Innovus power report

| frequency | internal power | switching power | total power | leakage power |
| --------- | -------------- | --------------- | ----------- | ------------- |
| 100 MHz   | 0.002028       | 0.0006917       | 0.003512    | 0.0007924     |
| 200 MHz   | 0.004056       | 0.001383        | 0.006232    | 0.0007924     |
| 300 MHz   | 0.006084       | 0.002075        | 0.008952    | 0.0007924     |
| 400 MHz   | 0.008112       | 0.002767        | 0.01167     | 0.0007924     |
| 500 MHz   | 0.01014        | 0.003459        | 0.01439     | 0.0007924     |
| 600 MHz   | 0.01217        | 0.00415         | 0.01711     | 0.0007924     |
| 700 MHz   | 0.0142         | 0.004842        | 0.01983     | 0.0007924     |
| 800 MHz   | 0.01622        | 0.005534        | 0.02255     | 0.0007924     |
| 900 MHz   | 0.01825        | 0.006225        | 0.02527     | 0.0007924     |
| 1000 MHz  | 0.02028        | 0.006917        | 0.02799     | 0.0007924     |

-  total internal power and total switching power vs. frequency

![Power vs Frequency](/project_3/power_vs_freq_plot.png)

### Q3.10

- area report from Innovus summary

```txt
==============================
Floorplan/Placement Information
==============================
Total area of Standard cells: 163.800 um^2  
Total area of Standard cells(Subtracting Physical Cells): 113.400 um^2  
Total area of Macros: 0.000 um^2  
Total area of Blockages: 0.000 um^2  
Total area of Pad cells: 0.000 um^2  
Total area of Core: 163.800 um^2  
Total area of Chip: 163.800 um^2  
Effective Utilization: 1.0000e+00  
Number of Cell Rows: 7  
% Pure Gate Density #1 (Subtracting BLOCKAGES): 100.000%  
% Pure Gate Density #2 (Subtracting BLOCKAGES and Physical Cells): 69.231%  
% Pure Gate Density #3 (Subtracting MACROS): 100.000%  
% Pure Gate Density #4 (Subtracting MACROS and Physical Cells): 69.231%  
% Pure Gate Density #5 (Subtracting MACROS and BLOCKAGES): 100.000%  
% Pure Gate Density #6 (Subtracting MACROS and BLOCKAGES for insts are not placed): 69.231%  
% Core Density (Counting Std Cells and MACROs): 100.000%  
% Core Density #2(Subtracting Physical Cells): 69.231%  
% Chip Density (Counting Std Cells and MACROs and IOs): 100.000%  
% Chip Density #2(Subtracting Physical Cells): 69.231%  
# Macros within 5 sites of IO pad: No  
Macro halo defined?: No  
```

- **area from Innovus: 163.800 um^2**
- **area from Synopsys synthesis: 113.400002 um^2**

The synthesizer only counts the accumulated standard cell area. It does not account for power lines, internal routings, and spacing between cells that are need for layout drc. These areas are counted in the Innovus layout area report, which is why the Innovus area is larger than the synthesis area. To confirm this, the Innovus report shows the "Total area of Standard cells(Subtracting Physical Cells): 113.400 um^2", which matches the synthesis area of 113.400002 um^2.

### Q3.11 Layout

- Innovus design layout with clean geometry check

![Layout](/project_3/innovus_layout_no_viols.png)

### Q3.12

```bash
ug253:~% cd ece1388/pj3
ug253:~/ece1388/pj3% ncverilog testbench.v multiplier_netlist.v tcbn65gplus.v
ncverilog(64): 15.20-s079: (c) Copyright 1995-2019 Cadence Design Systems, Inc.
file: multiplier_netlist.v
	module worklib.multiplier:v
		errors: 0, warnings: 0
		Caching library 'worklib' ....... Done
	Elaborating the design hierarchy:
	Building instance overlay tables: .................... Done
	Building instance specific data structures.
	Loading native compiled code:     .................... Done
	Design hierarchy summary:
		                  Instances  Unique
		Modules:                870     846
		UDPs:                  1394       4
		Primitives:            3658      10
		Timing outputs:          56      29
		Registers:              353     355
		Scalar wires:           361       -
		Expanded wires:           8       2
		Always blocks:           56      56
		Initial blocks:           1       1
		Timing checks:         4170       -
		Simulation timescale:   1ps
	Writing initial simulation snapshot: worklib.testbench:v
Loading snapshot worklib.testbench:v .................... Done
ncsim> source /CMC/tools/cadence/INCISIVE15.20.079_lnx86/tools/inca/files/ncsimrc
ncsim> run
Test Completed without Errors! :)
ncsim: *W,RNQUIE: Simulation is complete.
ncsim> exit
```