## 1.1

- **NMOS32 Testbench**  
  ![](/project_1/nmos32_tb.png)

- **PMOS64 Testbench**  
  ![](/project_1/pmos64_tb.png)

- **NMOS32 (Id/Vds)**  
  ![](/project_1/nmos32_iv.png)

- **PMOS64 (Id/Vds)**  
  ![](/project_1/pmos64_iv.png)

## 1.2

- **NMOS32 (Id/Vds)**  
  ![](/project_1/nmos32_iv.png)

- **NMOS32 (Id/Vgs)**  
  ![](/project_1/nmos32_iv_vgs_id.png)

- **PMOS32 (Id/Vds)**  
  ![](/project_1/pmos32_iv_vds_id.png)

- **PMOS32 (Id/Vgs)**  
  ![](/project_1/pmos32_iv_vds_id.png)
  
## 2.1

![](/project_1/q2_1_tb&sim_trans.png)
![](/project_1/q2_1_tb&sim_pa.png)
![](/project_1/q2_1_wf_pa.png)

from the Cdelay parameter sweep, when **td_diff = 0**, **Cdelay ≈ 9.343 fF**, which is the effective gate cap of the DUT.


## Q2.2 — Effective input capacitance per-µm for the 64:32 inverter

**Given**

* Lambda-based unit: 1 “unit” transistor has **W = 4λ**, **L = 2λ**.
* Technology: **λ = 30 nm ⇒ Lmin = 2λ = 60 nm**.
* DUT sizing: **Wp = 64 units**, **Wn = 32 units**.
* From Q2.1 tuning: **Cdelay = 9.343 fF** (the effective input capacitance of the DUT for delay).

**Widths**
$$
\begin{aligned}
W_p &= 64 \times 4\lambda \\
&= 64 \times 4 \times 30,\text{nm} \\
&= 64 \times 120,\text{nm} \\
&= 7680,\text{nm} \\
&= 7.68,\mu\text{m},\\[4pt]
W_n &= 32 \times 4\lambda \\
&= 32 \times 120,\text{nm} \\
&= 3840,\text{nm} \\
&= 3.84,\mu\text{m}.
\end{aligned}
$$

**Total gate width**
$$
W_{\text{tot}} = W_p + W_n = 7.68 + 3.84 = 11.52,\mu\text{m}.
$$

**Capacitance per unit gate width (effective, for delay)**
$$
C_{\text{per-}\mu\text{m}}
= \frac{C_{\text{delay}}}{W_{\text{tot}}}
= \frac{9.343,\text{fF}}{11.52,\mu\text{m}}
\approx 0.811,\text{fF}/\mu\text{m}.
$$


## Q2.3

![](/project_1/q2_3_tb&sim.png)

* Shaped input (with X1/X2):
  tpdf = −21.55 ps, tpdr = −17.45 ps, tpd = −19.50 ps
* Step input (no X1/X2, 1 ps edges):
  tpdf = −16.12 ps, tpdr = −11.28 ps, tpd = −13.70 ps

### % change in average delay

$$
%\Delta t_{pd}=\frac{t_{pd,\text{step}}-t_{pd,\text{shaped}}}{|t_{pd,\text{shaped}}|}\times100\%
= \frac{(-13.70)-(-19.50)}{19.50}\times100\%
\approx \boxed{+29.7\%}
$$
So the DUT is ~29.7% faster (smaller |tpd|) with the step input.

## Q2.4

![](/project_1/q2_4_tb&sim.png)

* tpdf = −21.69 ps, tpdr = −17.33 ps, tpd = −19.51 ps

###  % change in average delay

Percentage difference (tb_b vs shaped baseline):
$$
\frac{-19.51 - (-19.50)}{19.50}\times100\%
\approx \boxed{-0.05\%}
$$
so essentially no change, which is exactly what we expect if the DUT sees the same input slew and load in both benches.

## Q2.5

![](/project_1/q2_5_tb&sim.png)

* **FO4, step input (no X1/X2):**
  $|t_{\text{pdf,FO4}}| = 16.12$ ps, $|t_{\text{pdr,FO4}}| = 11.28$ ps
* **FO5, step input (you just ran):**
  $|t_{\text{pdf,FO5}}| = 25.42$ ps, $|t_{\text{pdr,FO5}}| = 19.63$ ps
* **Effective input gate cap (from Q2.1):** (C_\text{in} = 9.343) fF
  
  $C_{\text{in}} = 9.343$ fF

Use the “two-fanout difference” so output parasitics cancel:
$$
t_{5}-t_{4}=0.69,R,C_\text{in}
$$

* **Pull-down (nMOS on, FALL):**
  $$
  \begin{aligned}
  R_n &= \frac{25.42-16.12}{0.69\times 9.343}\ \text{ps/fF} \\
  &= \frac{9.30}{6.4467}\times 10^3\ \Omega \\
  &\approx \boxed{1.44\ \text{k}\Omega}
  \end{aligned}
  $$

* **Pull-up (pMOS on, RISE):**
  $$
  \begin{aligned}
  R_p &= \frac{19.63-11.28}{0.69\times 9.343}\ \text{ps/fF} \\
  &= \frac{8.35}{6.4467}\times 10^3\ \Omega \\
  &\approx \boxed{1.30\ \text{k}\Omega}
  \end{aligned}
  $$

The increment from FO4→FO5 is:
$$
\Delta t_{\text{fall}}=0.69,R_n,C_\text{in}\approx 9.30\ \text{ps},\quad
\Delta t_{\text{rise}}=0.69,R_p,C_\text{in}\approx 8.35\ \text{ps}.
$$

So predicted FO5 delays:
$$
\begin{aligned}
t_{\text{pdf,FO5,pred}} &= |t_{\text{pdf,FO4}}|+\Delta t_{\text{fall}} \\
&= 16.12+9.30 \approx \boxed{25.42\ \text{ps}},\\
t_{\text{pdr,FO5,pred}} &= |t_{\text{pdr,FO4}}|+\Delta t_{\text{rise}} \\
&= 11.28+8.35 \approx \boxed{19.63\ \text{ps}},\\
t_{\text{pd,FO5,pred}}  &= \frac{25.42+19.63}{2} \approx \boxed{22.53\ \text{ps}}.
\end{aligned}
$$

## Q3.1

![](/project_1/q3_1_tb&sim.png)

$$
\begin{aligned}
V_{OL} &= 55.05\ \text{mV}\\
V_{OH} &= 946.9\ \text{mV}\\
V_{IL} &= 382.5\ \text{mV}\\
V_{IH} &= 597.3\ \text{mV}\\
\mathrm{NM}_H &= 349.6\ \text{mV}\\
\mathrm{NM}_L &= 327.4\ \text{mV}
\end{aligned}
$$


## Q3.2

![](/project_1/q3_2_tb&sim.png)
![](/project_1/q3_2_wf.png)

$$
\begin{aligned}
W_n &= 3.84~\mu\text{m} \\
W_p^\star &\approx 9.502~\mu\text{m} \\
\frac{W_p^\star}{W_n} &\approx \frac{9.502}{3.84} \approx 2.4745 \\
\mathrm{NM}_{\text{eq}} &\approx 334.64~\text{mV}
\end{aligned}
$$

## Q3.3

$$
\begin{aligned}
\left(\frac{W_p}{W_n}\right)_{\text{opt}} &\approx 2.4745 \\
W_p^\star &= 2.4745 \times 32 = 79.18 \;\text{units} \\
&\approx 79 \;\text{units} \;\rightarrow\; \text{round to even: } 80 \\
\therefore\ \frac{W_p}{W_n} &= \frac{80}{32} = 2.5
\end{aligned}
$$

