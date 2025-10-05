From **Project 1**, it explicitly states:

> “The term ‘units’ refers to the number of multiples of a unit-sized transistor, i.e., first instantiate a transistor with unit-sized parameters of gate width = 4 and gate length = 2 (minimum gate length)”.

From **Lecture 2 (Layout slides)**, the “unit transistor” definition is:

> “Minimum size is 4λ / 2λ, sometimes called 1 unit”.

Thus, the **unit transistor** has:

* **Gate width = 4λ**
* **Gate length = 2λ (minimum length)**

Given that **λ = 30 nm** in this project, one unit corresponds to:

* **Width = 4λ = 120 nm**
* **Length = 2λ = 60 nm**

So for the **32:64 inverter**:

* **nMOS (Wn = 32 units)** → width = 32 × 4λ = 128λ = 3.84 µm
* **pMOS (Wp = 64 units)** → width = 64 × 4λ = 256λ = 7.68 µm