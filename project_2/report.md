# 1a

## Design Specifications

### System Parameters
- **Register File:** 32 words × 64 bits per word
- **Unit-size inverter:** $C_{inv} = 3$ (PMOS: 2λ, NMOS: 1λ)
- **Input load:** $C_{in} = 60$ (20 unit-size inverters, each with capacitance 3)
- **Output load:** $C_{out} = 192$ (64 bits × 3 unit transistor loads per bit)
- **Address bits:** A[4:0] (5 bits to decode 32 words)
- **Technology:** λ = 30nm, Vdd = 1V, T = 25°C

### Logical Effort Catalog (from Lecture Slides)

| Gate Type | Inputs | Logical Effort (g) | Parasitic Delay (p) |
| --------- | ------ | ------------------ | ------------------- |
| Inverter  | 1      | 1                  | 1                   |
| NAND2     | 2      | 4/3                | 2                   |
| NAND3     | 3      | 5/3                | 3                   |
| NAND4     | 4      | 6/3 = 2            | 4                   |
| NAND5     | 5      | 7/3                | 5                   |

**General Formula for NAND-n:** $g = \frac{n+2}{3}$, $p = n$

### Key Formulas

**Path Effort:**
$F = G \times B \times H$

Where:
- $G = \prod g_i$ (Path Logical Effort)
- $B = 16$ (Branching Effort - global to all decoder slices)
- $H = \frac{C_{out}}{C_{in}} = \frac{192}{60} = 3.2$ (Electrical Effort)

**Best Stage Effort:**
$\hat{f} = F^{1/N}$

**Path Delay:**
$D = N\hat{f} + P$

Where $P = \sum p_i$ (Path Parasitic Delay)

**Gate Sizing (working backward from output):**
$C_{in,i} = \frac{g_i \cdot C_{out,i}}{\hat{f}}$

---

## Architecture 1: NAND5-INV (N=2)

### Stage Configuration
```
INPUT (Cin=60) → NAND5 → INV → OUTPUT (Cout=192)
                  (Y)      (Z)
```

### Calculations

**Path Logical Effort:**
$G = g_{NAND5} \times g_{INV} = \frac{7}{3} \times 1 = 2.333$

**Electrical Effort:**
$H = \frac{192}{60} = 3.2$

**Branching Effort:**
$B = 16$

**Path Effort:**
$F = G \times B \times H = 2.333 \times 16 \times 3.2 = 119.47$

**Best Stage Effort:**
$\hat{f} = F^{1/2} = \sqrt{119.47} = 10.93$

**Path Parasitic Delay:**
$P = p_{NAND5} + p_{INV} = 5 + 1 = 6$

**Path Delay:**
$D = 2 \times 10.93 + 6 = \boxed{27.86 \tau}$

### Gate Sizing (Working Backward)

**Stage 2 (INV):**
$C_{in,INV} = \frac{g_{INV} \times C_{out}}{\hat{f}} = \frac{1 \times 192}{10.93} = 17.57$

Size relative to unit inverter:
$Z = \frac{17.57}{3} = \boxed{5.86}$

**Stage 1 (NAND5):**
$C_{in,NAND5} = \frac{g_{NAND5} \times C_{in,INV}}{\hat{f}} = \frac{(7/3) \times 17.57}{10.93} = 3.76$

Size relative to unit NAND5 (Cin = 7):
$Y = \frac{3.76}{7} = \boxed{0.54}$

**Verification:** 
$C_{in,total} = Y \times 7 \times B = 0.54 \times 7 \times 16 = 60.48 \approx 60 \checkmark$

---

## Architecture 2: INV-NAND5-INV (N=3)

### Stage Configuration
```
INPUT (60) → INV → NAND5 → INV → OUTPUT (192)
              (X)    (Y)      (Z)
```

### Calculations

**Path Logical Effort:**
$G = g_{INV} \times g_{NAND5} \times g_{INV} = 1 \times \frac{7}{3} \times 1 = 2.333$

**Path Effort:**
$F = 2.333 \times 16 \times 3.2 = 119.47$

**Best Stage Effort:**
$\hat{f} = F^{1/3} = \sqrt[3]{119.47} = 4.92$

**Path Parasitic Delay:**
$P = p_{INV} + p_{NAND5} + p_{INV} = 1 + 5 + 1 = 7$

**Path Delay:**
$D = 3 \times 4.92 + 7 = \boxed{21.76 \tau}$

### Gate Sizing

**Stage 3 (INV):**
$C_{in,3} = \frac{1 \times 192}{4.92} = 39.02$
$Z = \frac{39.02}{3} = \boxed{13.01}$

**Stage 2 (NAND5):**
$C_{in,2} = \frac{(7/3) \times 39.02}{4.92} = 18.56$
$Y = \frac{18.56}{7} = \boxed{2.65}$

**Stage 1 (INV):**
$C_{in,1} = \frac{1 \times 18.56}{4.92} = 3.77$
$X = \frac{3.77}{3} = \boxed{1.26}$

**Verification:**
$C_{in,total} = X \times 3 \times B = 1.26 \times 3 \times 16 = 60.48 \approx 60 \checkmark$

---

## Architecture 3: INV-INV-NAND5-INV (N=4)

### Stage Configuration
```
INPUT (60) → INV → INV → NAND5 → INV → OUTPUT (192)
              (W)   (X)    (Y)      (Z)
```

### Calculations

**Path Logical Effort:**
$G = 1 \times 1 \times \frac{7}{3} \times 1 = 2.333$

**Path Effort:**
$F = 2.333 \times 16 \times 3.2 = 119.47$

**Best Stage Effort:**
$\hat{f} = F^{1/4} = \sqrt[4]{119.47} = 3.306$

**Path Parasitic Delay:**
$P = 1 + 1 + 5 + 1 = 8$

**Path Delay:**
$D = 4 \times 3.306 + 8 = \boxed{21.22 \tau}$

### Gate Sizing

To meet the input capacitance requirement of 60C, we work forward from the input constraint:

**Stage 1 (INV):**
$C_{in,1} = \frac{60}{16} = 3.75$
$W = \frac{3.75}{3} = \boxed{1.25}$

**Stage 2 (INV):**
$C_{in,2} = \frac{1 \times 3.75 \times 3.306}{1} = 12.40$
$X = \frac{12.40}{3} = \boxed{4.13}$

**Stage 3 (NAND5):**
$C_{in,3} = \frac{1 \times 12.40 \times 3.306}{1} = 40.99$
$Y = \frac{40.99}{7} = \boxed{5.86}$

**Stage 4 (INV):**
$C_{in,4} = \frac{(7/3) \times 40.99 \times 3.306}{(7/3)} = 58.07$
$Z = \frac{58.07}{3} = \boxed{19.36}$

**Verification:**
$C_{in,total} = W \times 3 \times B = 1.25 \times 3 \times 16 = 60.0 \checkmark$

---

## Architecture 4: NAND2/3-INV-NAND2-INV (N=4, Tree)

### Stage Configuration

This architecture uses a **tree structure** with two paths that converge:

```
        ┌─→ NAND3 (W1) ─┐
INPUT ──┤              ├─→ INV (Y) ─→ NAND2 (X) ─→ INV (Z) ─→ OUTPUT
        └─→ NAND2 (W2) ─┘
```

**Path 1 (NAND3):** Takes 3 address bits
**Path 2 (NAND2):** Takes 2 address bits

### Path 1: NAND3 Branch

**Path Logical Effort:**
$G_1 = g_{NAND3} \times g_{INV} \times g_{NAND2} \times g_{INV} = \frac{5}{3} \times 1 \times \frac{4}{3} \times 1 = \frac{20}{9} = 2.222$

**Path Effort:**
$F_1 = G_1 \times B \times H = 2.222 \times 16 \times 3.2 = 113.78$

**Best Stage Effort:**
$\hat{f}_1 = F_1^{1/4} = \sqrt[4]{113.78} = 3.27$

**Path Parasitic Delay:**
$P_1 = p_{NAND3} + p_{INV} + p_{NAND2} + p_{INV} = 3 + 1 + 2 + 1 = 7$

**Path Delay:**
$D_1 = 4 \times 3.27 + 7 = 20.08 \tau$

### Path 2: NAND2 Branch

**Path Logical Effort:**
$G_2 = g_{NAND2} \times g_{INV} \times g_{NAND2} \times g_{INV} = \frac{4}{3} \times 1 \times \frac{4}{3} \times 1 = \frac{16}{9} = 1.778$

**Path Effort:**
$F_2 = G_2 \times B \times H = 1.778 \times 16 \times 3.2 = 91.02$

**Best Stage Effort:**
$\hat{f}_2 = F_2^{1/4} = \sqrt[4]{91.02} = 3.08$

**Path Parasitic Delay:**
$P_2 = p_{NAND2} + p_{INV} + p_{NAND2} + p_{INV} = 2 + 1 + 2 + 1 = 6$

**Path Delay:**
$D_2 = 4 \times 3.08 + 6 = 18.32 \tau$

### Critical Path

**Worst-case delay:** $D = \max(D_1, D_2) = \boxed{20.08 \tau}$

### Gate Sizing

Using the **critical path (Path 1)** stage effort $\hat{f}_1 = 3.27$:

**Stage 4 (INV - common):**

$C_{in,4} = \frac{1 \times 192}{3.27} = 58.72$

$Z = \frac{58.72}{3} = \boxed{19.57}$

**Stage 3 (NAND2 - common):**

$C_{in,3} = \frac{(4/3) \times 58.72}{3.27} = 23.92$

$X = \frac{23.92}{4} = \boxed{5.98}$

**Stage 2 (INV - common):**

$C_{in,2} = \frac{1 \times 23.92}{3.27} = 7.32$

$Y = \frac{7.32}{3} = \boxed{2.44}$

**Stage 1a (NAND3 - Path 1):**

$C_{in,1a} = \frac{(5/3) \times 7.32}{3.27} = 3.73$

$W1 = \frac{3.73}{5} = \boxed{0.75}$

**Stage 1b (NAND2 - Path 2):**

Using Path 2's stage effort $\hat{f}_2 = 3.08$ for non-critical path gates:

$C_{in,1b} = \frac{(4/3) \times 7.32}{3.08} = 3.17$

$W2 = \frac{3.17}{4} = \boxed{0.79}$

---

## Architecture 5: INV-NAND2/3-INV-NAND2-INV (N=5, Tree)

### Stage Configuration

```
            ┌─→ NAND3 (V1) ─┐
INPUT → INV ─┤              ├─→ INV (X) ─→ NAND2 (W) ─→ INV (Z) ─→ OUTPUT
        (U) └─→ NAND2 (V2) ─┘
```

### Path 1: NAND3 Branch

**Path Logical Effort:**
$G_1 = 1 \times \frac{5}{3} \times 1 \times \frac{4}{3} \times 1 = \frac{20}{9} = 2.222$

**Path Effort:**
$F_1 = 2.222 \times 16 \times 3.2 = 113.78$

**Best Stage Effort:**
$\hat{f}_1 = F_1^{1/5} = \sqrt[5]{113.78} = 2.59$

**Path Parasitic Delay:**
$P_1 = 1 + 3 + 1 + 2 + 1 = 8$

**Path Delay:**
$D_1 = 5 \times 2.59 + 8 = 20.95 \tau$

### Path 2: NAND2 Branch

**Path Logical Effort:**
$G_2 = 1 \times \frac{4}{3} \times 1 \times \frac{4}{3} \times 1 = \frac{16}{9} = 1.778$

**Path Effort:**
$F_2 = 1.778 \times 16 \times 3.2 = 91.02$

**Best Stage Effort:**
$\hat{f}_2 = F_2^{1/5} = \sqrt[5]{91.02} = 2.49$

**Path Parasitic Delay:**
$P_2 = 1 + 2 + 1 + 2 + 1 = 7$

**Path Delay:**
$D_2 = 5 \times 2.49 + 7 = 19.45 \tau$

### Critical Path

**Worst-case delay:** $D = \max(D_1, D_2) = \boxed{20.95 \tau}$

### Gate Sizing

Using critical path (Path 1) stage effort $\hat{f}_1 = 2.59$:

**Stage 5 (INV):**

$C_{in,5} = \frac{1 \times 192}{2.59} = 74.13$

$Z = \frac{74.13}{3} = \boxed{24.71}$

**Stage 4 (NAND2):**

$C_{in,4} = \frac{(4/3) \times 74.13}{2.59} = 38.06$

$W = \frac{38.06}{4} = \boxed{9.52}$

**Stage 3 (INV):**

$C_{in,3} = \frac{1 \times 38.06}{2.59} = 14.70$

$X = \frac{14.70}{3} = \boxed{4.90}$

**Stage 2a (NAND3 - Path 1):**

$C_{in,2a} = \frac{(5/3) \times 14.70}{2.59} = 9.47$

$V1 = \frac{9.47}{5} = \boxed{1.89}$

**Stage 2b (NAND2 - Path 2):**

Using Path 2's stage effort $\hat{f}_2 = 2.49$:

$C_{in,2b} = \frac{(4/3) \times 14.70}{2.49} = 7.84$

$V2 = \frac{7.84}{4} = \boxed{1.96}$

**Stage 1 (INV):**

$C_{in,1} = \frac{1 \times 9.47}{2.59} = 3.66$

$U = \frac{3.66}{3} = \boxed{1.22}$

---

## Architecture 6: INV-INV-NAND2/3-INV-NAND2-INV (N=6, Tree)

### Stage Configuration

```
                ┌─→ NAND3 (W1) ─┐
INPUT → INV → INV ─┤              ├─→ INV (X) ─→ NAND2 (Y) ─→ INV (Z) ─→ OUTPUT
        (U)   (V) └─→ NAND2 (W2) ─┘
```

### Path 1: NAND3 Branch

**Path Logical Effort:**
$G_1 = 1 \times 1 \times \frac{5}{3} \times 1 \times \frac{4}{3} \times 1 = \frac{20}{9} = 2.222$

**Path Effort:**
$F_1 = 2.222 \times 16 \times 3.2 = 113.78$

**Best Stage Effort:**
$\hat{f}_1 = F_1^{1/6} = \sqrt[6]{113.78} = 2.201$

**Path Parasitic Delay:**
$P_1 = 1 + 1 + 3 + 1 + 2 + 1 = 9$

**Path Delay:**
$D_1 = 6 \times 2.201 + 9 = \boxed{22.21 \tau}$

### Path 2: NAND2 Branch

**Path Logical Effort:**
$G_2 = 1 \times 1 \times \frac{4}{3} \times 1 \times \frac{4}{3} \times 1 = \frac{16}{9} = 1.778$

**Path Effort:**
$F_2 = 1.778 \times 16 \times 3.2 = 91.03$

**Best Stage Effort:**
$\hat{f}_2 = F_2^{1/6} = \sqrt[6]{91.03} = 2.121$

**Path Parasitic Delay:**
$P_2 = 1 + 1 + 2 + 1 + 2 + 1 = 8$

**Path Delay:**
$D_2 = 6 \times 2.121 + 8 = \boxed{20.73 \tau}$

### Critical Path

**Worst-case delay:** $D = \max(D_1, D_2) = \boxed{22.21 \tau}$

### Gate Sizing

Using the **critical path (Path 1)** stage effort $\hat{f}_1 = 2.201$ for all **common stages** (Z, Y, X, V, U). Size the **non-common gate** (W2) with its own path's stage effort $\hat{f}_2 = 2.121$.

**Stage 6 (INV - common):**
$C_{in,6} = \frac{1 \times 192}{2.201} = 87.22$
$Z = \frac{87.22}{3} = \boxed{29.07}$

**Stage 5 (NAND2 - common):**
$C_{in,5} = \frac{(4/3) \times 87.22}{2.201} = 52.83$
$Y = \frac{52.83}{4} = \boxed{13.21}$

**Stage 4 (INV - common):**
$C_{in,4} = \frac{1 \times 52.83}{2.201} = 24.00$
$X = \frac{24.00}{3} = \boxed{8.00}$

**Stage 3a (NAND3 - Path 1):**
$C_{in,3a} = \frac{(5/3) \times 24.00}{2.201} = 18.17$
$W1 = \frac{18.17}{5} = \boxed{3.63}$

**Stage 3b (NAND2 - Path 2):**
Using Path 2's stage effort $\hat{f}_2 = 2.121$:
$C_{in,3b} = \frac{(4/3) \times 24.00}{2.121} = 15.09$
$W2 = \frac{15.09}{4} = \boxed{3.77}$

**Stage 2 (INV - common):**
$C_{in,2} = \frac{1 \times 18.17}{2.201} = 8.25$
$V = \frac{8.25}{3} = \boxed{2.75}$

**Stage 1 (INV - common):**
$C_{in,1} = \frac{1 \times 8.25}{2.201} = 3.75$
$U = \frac{3.75}{3} = \boxed{1.25}$

**Verification:**
$C_{in,total} = U \times 3 \times B = 1.25 \times 3 \times 16 = 60.0 \checkmark$

*Note: Common gates are sized with $\hat{f}_1$ to ensure the critical path meets the 60C input capacitance requirement; the non-critical path remains faster.*

---

# 1b

| Design Architecture           | N     | G         | P     | D (τ)     | Z         | Y        | X        | W                      | V     | U     |
| ----------------------------- | ----- | --------- | ----- | --------- | --------- | -------- | -------- | ---------------------- | ----- | ----- |
|                               |       |           |       |           |           |          |          |                        |       |       |
| NAND5-INV                     | 2     | 2.333     | 6     | 27.86     | 5.86      | 0.54     | -        | -                      | -     | -     |
| INV-NAND5-INV                 | 3     | 2.333     | 7     | 21.76     | 13.01     | 2.65     | 1.26     | -                      | -     | -     |
| INV-INV-NAND5-INV             | 4     | 2.333     | 8     | 21.22     | 19.36     | 5.86     | 4.13     | 1.25                   | -     | -     |
| **NAND2/3-INV-NAND2-INV**     | **4** | **2.222** | **7** | **20.08** | **19.57** | **5.98** | **2.44** | **W1:0.75<br>W2:0.79** | **-** | **-** |
| INV-NAND2/3-INV-NAND2-INV     | 5     | 2.222     | 8     | 20.95     | 24.71     | 9.52     | 4.90     | W1:1.89<br>W2:1.96     | 1.22  | -     |
| INV-INV-NAND2/3-INV-NAND2-INV | 6     | 2.222     | 9     | 22.21     | 29.07     | 13.21    | 8.00     | W1:3.63<br>W2:3.77     | 2.75  | 1.25  |

Thus, the fastest design is the **NAND2/3-INV-NAND2-INV** with a delay of **20.08 τ**.

---

# 1c

**Given:**

* Chain: **NAND3 (W1)**, **NAND2 (W2)** ⇒ **two INVs (Y3, Y2)** ⇒ **NAND2 (X)** ⇒ **INV (Z)** ⇒ **wordline**
* Sizes (normalized to unit inverter input (=3) C_units):
   $$
   \begin{aligned}
   &Z:;19.57 \Rightarrow C_{\text{in},Z}=3\cdot19.57=58.71\\
   &X:;5.98 \Rightarrow C_{\text{in},X}=4\cdot5.98=23.92\quad(\text{both inputs total})\\
   &Y:;2.44;\text{total}\Rightarrow \text{split} ; (Y2,Y3); \text{each of size }1.22 \Rightarrow C_{\text{in},Y\text{(branch)}}=3.66\\
   &W1:;C_{\text{in},1a}=3.73\quad(\text{NAND3})\qquad
   W2:;C_{\text{in},1b}=3.17\quad(\text{NAND2})
   \end{aligned}
   $$
* Wordline load: $(64\times 3=192)$ C_units.
* Update rate: $(f=1,\text{MHz})$, $(V_{DD}=1,\text{V})$.
* Rolling address ($0\to31$) (1 update per ($\mu s$)).

---

## Activity factors ($\alpha$)

A single wordline toggles 2 times every 32 updates:
$$
\alpha_Z=\frac{2}{32}=\frac{1}{16},\qquad \alpha_X=\frac{1}{16}.
$$
Predecode branches under rolling count:
$$
\alpha_{Y2}=\alpha_{W2}=\frac{1}{2}\quad(2\text{-bit group}),\qquad
\alpha_{Y3}=\alpha_{W1}=\frac{1}{4}\quad(3\text{-bit group}).
$$

---

## Node capacitances ($C_i$) (sum of **load gates** + **output diffusion**)

Use LE parasitics as diffusion proxy: ($C_{\text{diff,out}}\approx \frac{p}{3}C_{\text{in,stage}}$) with
(($p_{\text{INV}},p_{\text{N2}},p_{\text{N3}}$)=$(1,2,3)$).

1. **Z (wordline):**
   $$
   \begin{aligned}
   C_Z &= 192 + \frac{1}{3}C_{\text{in},Z}\\
       &= 192 + \frac{1}{3}\cdot 58.71\\
       &= \mathbf{211.57}.
   \end{aligned}
   $$

2. **X (out of NAND2):**
   $$
   \begin{aligned}
   C_X &= C_{\text{in},Z} + \frac{2}{3}C_{\text{in},X}\\
       &= 58.71 + \frac{2}{3}\cdot 23.92\\
       &= \mathbf{74.66}.
   \end{aligned}
   $$

3. **Y2, Y3 (each branch INV output):**
   $$
   \begin{aligned}
   C_{Y\bullet} &= C_{\text{in of one }X\text{ input}} + \frac{1}{3}C_{\text{in},Y\text{(branch)}}\\
                 &= 11.96 + \frac{1}{3}\cdot 3.66\\
                 &= \mathbf{13.18}.
   \end{aligned}
   $$

4. **W1 (out of NAND3):**
   $$
   \begin{aligned}
   C_{W1} &= C_{\text{in},Y\text{(branch)}} + \frac{3}{3}C_{\text{in},1a}\\
          &= 3.66 + 3.73\\
          &= \mathbf{7.39}.
   \end{aligned}
   $$

5. **W2 (out of NAND2):**
   $$
   \begin{aligned}
   C_{W2} &= C_{\text{in},Y\text{(branch)}} + \frac{2}{3}C_{\text{in},1b}\\
          &= 3.66 + \frac{2}{3}\cdot 3.17\\
          &= \mathbf{5.77}.
   \end{aligned}
   $$

---

## Power (normalized units)

Dynamic power summed **per switching node**:
$$
P=\sum_i \alpha_i, C_i, V_{DD}^2, f.
$$
With (V_{DD}=1) and (f=1,\text{MHz}):
$$
\begin{aligned}
P_Z   &= \tfrac{1}{16}\cdot 211.57 = 13.223,\\
P_X   &= \tfrac{1}{16}\cdot 74.66  = 4.666,\\
P_{Y2}&= \tfrac{1}{2}\cdot 13.18   = 6.590,\\
P_{Y3}&= \tfrac{1}{4}\cdot 13.18   = 3.295,\\
P_{W2}&= \tfrac{1}{2}\cdot 5.77    = 2.887,\\
P_{W1}&= \tfrac{1}{4}\cdot 7.39    = 1.848.
\end{aligned}
$$
$$
\boxed{P_{\text{slice}} = 32.51;;(\text{C\_unit})\cdot V^2\cdot \text{MHz}}
$$