import 'package:flutter/material.dart';

class PathwayUI extends StatefulWidget {
  List dummyData = [
    {
      "unit": "Numbers and Operations",
      "unit_id": 1,
      "subtopics": [
        {
          "subtopic": "Repeating Decimals",
          "subtopic_id": 1,
          "reading": {
            "title": "Understanding Repeating Decimals",
            "content": "A repeating decimal is a decimal number where one or more digits repeat infinitely. These numbers arise when dividing integers that do not result in terminating decimals. For example:\n\n- 1 ÷ 3 = 0.333… (3 repeats indefinitely)\n- 2 ÷ 7 = 0.285714285714… (285714 repeats indefinitely)\n\n### Identifying Repeating Decimals:\nRepeating decimals are usually represented with a bar notation: \n- 0.333… = 0.\u03053 (bar over 3)\n- 0.285714285714… = 0.\u0305285714 (bar over 285714)\n\n### Converting Repeating Decimals to Fractions:\nWe can express repeating decimals as fractions using algebra. Example:\n1. Let x = 0.\u03053 (which means 0.333…)\n2. Multiply by 10: 10x = 3.333…\n3. Subtract the original equation: 10x - x = 3.333… - 0.333…\n4. Simplify: 9x = 3 → x = 3/9 = 1/3\n\nThis technique works for any repeating decimal. \n\nUnderstanding repeating decimals is essential in algebra, number theory, and rational number operations."
          },
          "quizPool": [201, 202, 203, 204, 205, 206, 207, 208, 209, 210]
        },
        {
          "subtopic": "Square Roots & Cube Roots",
          "subtopic_id": 2,
          "reading": {
            "title": "Mastering Square and Cube Roots",
            "content": "### Understanding Square Roots:\nThe **square root** of a number is a value that, when multiplied by itself, gives the original number. \n- Example: √9 = 3 because 3 × 3 = 9\n- Not all numbers have perfect square roots. For instance, √10 is **irrational** and approximately 3.162.\n\n### Properties of Square Roots:\n- √a × √b = √(a × b) → Example: √4 × √9 = √(4 × 9) = √36 = 6\n- (√a)^2 = a → Example: (√7)^2 = 7\n- Rationalizing: 1/√2 = (1 × √2) / (√2 × √2) = √2/2\n\n### Understanding Cube Roots:\nThe **cube root** of a number is a value that, when multiplied three times by itself, gives the original number.\n- Example: ∛27 = 3 because 3 × 3 × 3 = 27\n\n### Properties of Cube Roots:\n- ∛a × ∛b = ∛(a × b)\n- (∛a)^3 = a\n\n### Real-Life Applications:\n- **Engineering & Architecture**: Calculating diagonal lengths using square roots.\n- **Physics**: Cube roots appear in volume and density calculations.\n- **Finance**: Square roots are used in interest rate calculations.\n\nMastering these roots is foundational for algebra, geometry, and higher mathematics."
          },
          "quizPool": [211, 212, 213, 214, 215, 216, 217, 218, 219, 220]
        },
        {
          "subtopic": "Irrational Numbers",
          "subtopic_id": 3,
          "reading": {
            "title": "Introduction to Irrational Numbers",
            "content": "### Definition:\nAn **irrational number** is a number that **cannot be expressed as a simple fraction (a/b)** where a and b are integers. Irrational numbers have **non-repeating, non-terminating decimal expansions**.\n\n### Examples:\n- π (3.141592653...) is irrational because it **never ends and never repeats**.\n- √2 (1.414213562...) is irrational because it **cannot be written as a fraction**.\n\n### Differences Between Rational and Irrational Numbers:\n| **Property**  | **Rational Numbers** | **Irrational Numbers** |\n|--------------|--------------------|----------------------|\n| **Decimal Form** | Terminates or repeats | Non-terminating, non-repeating |\n| **Fraction Form** | Can be written as a/b | Cannot be written as a/b |\n| **Examples** | 1/2 = 0.5, 1/3 = 0.333… | π, √5, e (Euler’s number) |\n\n### Why Are Irrational Numbers Important?\n- They help define **real numbers**.\n- They appear in **geometry** (e.g., the diagonal of a square with side length 1 is √2).\n- Used in **physics, engineering, and advanced mathematics**.\n\n### Approximating Irrational Numbers:\nSince irrational numbers cannot be written exactly, we often **approximate** them:\n- π ≈ 3.14 or 22/7\n- √2 ≈ 1.414\n\nMastering irrational numbers is crucial for algebra, trigonometry, and real analysis."
          },
          "quizPool": [221, 222, 223, 224, 225, 226, 227, 228, 229, 230]
        },
        {
          "subtopic": "Approximating Irrational Numbers",
          "subtopic_id": 4,
          "reading": {
            "title": "Techniques for Approximating Irrational Numbers",
            "content": "### Why Approximate Irrational Numbers?\nIrrational numbers **cannot be written exactly** as fractions or decimals. To use them in calculations, we must approximate them.\n\n### Common Approximation Techniques:\n1. **Using Rounded Values**\n   - π ≈ 3.14 or 22/7\n   - √2 ≈ 1.414, √3 ≈ 1.732\n   - These approximations are useful for **quick calculations**.\n\n2. **Using a Number Line**\n   - We can locate irrational numbers by estimating their position.\n   - Example: √5 is between **2.2 and 2.3** because 2.2² = 4.84 and 2.3² = 5.29.\n\n3. **Using Continued Fractions**\n   - Irrational numbers can be approximated by fractions:\n   - Example: π ≈ 3.141592653… can be approximated using the fraction 355/113.\n\n4. **Using Decimal Expansion**\n   - Example: √2 = 1.414213...\n   - By cutting off digits, we get approximations like **1.41 or 1.414**.\n\n### Application of Approximations:\n- **Geometry**: Approximating **π** in circle calculations.\n- **Engineering**: Approximating **square roots** in construction.\n- **Finance**: Using approximations in **interest rate** calculations.\n\nApproximating irrational numbers is a key skill for algebra, geometry, and real-world problem-solving."
          },
          "quizPool": [231, 232, 233, 234, 235, 236, 237, 238, 239, 240]
        },
        {
          "subtopic": "Exponents with Negative Bases",
          "subtopic_id": 5,
          "reading": {
            "title": "Understanding Exponents with Negative Bases",
            "content": "### What Happens When a Base is Negative?\nWhen raising a **negative number** to an exponent, the **sign of the result depends on whether the exponent is even or odd**.\n\n### Rules:\n- **Even exponent → Positive result**\n  - (-2)^2 = (-2) × (-2) = **4**\n  - (-5)^4 = (-5) × (-5) × (-5) × (-5) = **625**\n\n- **Odd exponent → Negative result**\n  - (-2)^3 = (-2) × (-2) × (-2) = **-8**\n  - (-3)^5 = (-3) × (-3) × (-3) × (-3) × (-3) = **-243**\n\n### Properties:\n| **Exponent** | **Example** | **Result** |\n|-------------|------------|------------|\n| **Even**    | (-4)^2     | 16         |\n| **Odd**     | (-4)^3     | -64        |\n\n### Real-Life Applications:\n- **Physics**: Negative exponents appear in wave functions.\n- **Computer Science**: Used in binary exponentiation.\n- **Finance**: Exponential growth and decay formulas.\n\nUnderstanding exponents with negative bases is crucial for algebra, trigonometry, and calculus."
          },
          "quizPool": [241, 242, 243, 244, 245, 246, 247, 248, 249, 250]
        },
        {
          "subtopic": "Exponent Properties Intro",
          "subtopic_id": 6,
          "reading": {
            "title": "Fundamentals of Exponent Properties",
            "content": "### What are Exponent Rules?\nExponents help **simplify repeated multiplication**. Mastering exponent rules is essential for algebra.\n\n### Key Rules:\n1. **Product Rule**: When multiplying numbers with the same base, **add the exponents**.\n   - a^m × a^n = a^(m+n)\n   - Example: 2^3 × 2^4 = 2^(3+4) = **2^7**\n\n2. **Quotient Rule**: When dividing numbers with the same base, **subtract the exponents**.\n   - a^m / a^n = a^(m-n)\n   - Example: 5^6 ÷ 5^2 = 5^(6-2) = **5^4**\n\n3. **Power Rule**: When raising a power to another power, **multiply the exponents**.\n   - (a^m)^n = a^(m*n)\n   - Example: (3^2)^3 = 3^(2×3) = **3^6**\n\n### Additional Rules:\n- **Zero Exponent Rule**: a^0 = **1**\n  - Example: 7^0 = **1**\n- **Negative Exponent Rule**: a^(-n) = **1/a^n**\n  - Example: 2^-3 = **1/2^3 = 1/8**\n\n### Why is This Important?\n- **Physics & Engineering**: Used in formulas like E=mc².\n- **Computer Science**: Algorithms use exponentiation.\n- **Finance**: Interest calculations use exponents.\n\nMastering exponent rules is essential for simplifying algebraic expressions and solving equations."
          },
          "quizPool": [251, 252, 253, 254, 255, 256, 257, 258, 259, 260]
        },
        {
          "subtopic": "Negative Exponents",
          "subtopic_id": 10,
          "reading": {
            "title": "Understanding Negative Exponents",
            "content": "### What Do Negative Exponents Mean?\nA negative exponent **does not** make a number negative. Instead, it represents a **reciprocal**.\n\n### Rule:\n- a^(-n) = **1 / a^n**\n- Example: 2^(-3) = **1 / 2^3 = 1/8**\n\n### Examples:\n| **Expression**  | **Rewritten Form** | **Result** |\n|---------------|----------------|---------|\n| 5^(-2)       | 1 / 5^2        | 1/25    |\n| 10^(-4)      | 1 / 10^4       | 0.0001  |\n| (3/4)^(-2)   | (4/3)^2        | 16/9    |\n\n### Why Do We Use Negative Exponents?\n- **Scientific Notation**: Used to represent small numbers (e.g., 3.5 × 10^-4 = 0.00035).\n- **Algebraic Simplifications**: Helps simplify fractions with exponents.\n- **Physics & Chemistry**: Used for microscopic measurements (e.g., atomic radius, light wavelength).\n\nMastering negative exponents is essential for **scientific notation, exponential equations, and algebraic manipulation**."
          },
          "quizPool": [291, 292, 293, 294, 295, 296, 297, 298, 299, 300]
        },
        {
          "subtopic": "Exponent Properties (Integer Exponents)",
          "subtopic_id": 11,
          "reading": {
            "title": "Exploring Exponent Properties with Integer Exponents",
            "content": "### What Are Integer Exponents?\nInteger exponents include **positive, negative, and zero exponents**. They follow key rules:\n\n### Key Rules:\n1. **Product Rule**: Multiply numbers with the same base → **Add the exponents**.\n   - Example: 2^3 × 2^4 = 2^(3+4) = **2^7**\n\n2. **Quotient Rule**: Divide numbers with the same base → **Subtract the exponents**.\n   - Example: 7^5 ÷ 7^2 = 7^(5-2) = **7^3**\n\n3. **Power of a Power Rule**: (a^m)^n = **a^(m×n)**\n   - Example: (3^2)^4 = 3^(2×4) = **3^8**\n\n4. **Zero Exponent Rule**: Any number raised to **zero** is 1.\n   - Example: 9^0 = **1**\n\n5. **Negative Exponent Rule**: a^(-n) = **1 / a^n**\n   - Example: 5^(-3) = 1/5^3 = **1/125**\n\n### Applications:\n- **Physics & Chemistry**: Exponential decay in radioactive elements.\n- **Finance**: Compound interest calculations.\n- **Computer Science**: Algorithm complexity (e.g., O(2^n) growth rates).\n\nUnderstanding integer exponents is a **fundamental skill in algebra, calculus, and real-world applications**."
          },
          "quizPool": [301, 302, 303, 304, 305, 306, 307, 308, 309, 310]
        },
        {
          "subtopic": "Working with Powers of 10",
          "subtopic_id": 12,
          "reading": {
            "title": "Mastering Powers of 10",
            "content": "### What Are Powers of 10?\nPowers of 10 simplify **large and small numbers** using exponents.\n\n### Rules:\n- 10^3 = **1,000**\n- 10^-2 = **0.01** (1/100)\n- 10^0 = **1**\n\n### Scientific Notation & Powers of 10:\nScientific notation expresses numbers as **a × 10^n**.\n- Example: 5,600,000 = **5.6 × 10^6**\n- Example: 0.00042 = **4.2 × 10^-4**\n\n### Real-World Applications:\n- **Astronomy**: The Sun’s mass is **1.989 × 10^30 kg**.\n- **Medicine**: Bacteria sizes use **micrometers (10^-6 meters)**.\n- **Finance**: National debt is often written in scientific notation.\n\nPowers of 10 are essential for **scientific notation, metric conversions, and handling large numbers in calculations**."
          },
          "quizPool": [311, 312, 313, 314, 315, 316, 317, 318, 319, 320]
        },
        {
          "subtopic": "Scientific Notation Intro",
          "subtopic_id": 13,
          "reading": {
            "title": "Introduction to Scientific Notation",
            "content": "### What Is Scientific Notation?\nScientific notation expresses **very large or very small numbers** in the form:\n  - **a × 10^n**, where **1 ≤ a < 10** and **n is an integer**.\n\n### Examples:\n- **Large numbers:**\n  - 2,500,000 = **2.5 × 10^6**\n  - 1,000,000,000 = **1 × 10^9**\n\n- **Small numbers:**\n  - 0.0004 = **4 × 10^-4**\n  - 0.00000052 = **5.2 × 10^-7**\n\n### Why Use Scientific Notation?\n- **Simplifies calculations** for large and small numbers.\n- **Used in astronomy** (e.g., distance between planets).\n- **Essential in chemistry** (e.g., atomic mass units).\n\nMastering scientific notation is key for **engineering, physics, and mathematical modeling**."
          },
          "quizPool": [321, 322, 323, 324, 325, 326, 327, 328, 329, 330]
        },
        {
          "subtopic": "Arithmetic with Numbers in Scientific Notation",
          "subtopic_id": 14,
          "reading": {
            "title": "Performing Arithmetic with Scientific Notation",
            "content": "Addition and subtraction require adjusting exponents to be the same. Multiplication follows (a × 10^m) × (b × 10^n) = (a × b) × 10^(m+n), while division follows (a × 10^m) ÷ (b × 10^n) = (a/b) × 10^(m-n)."
          },
          "quizPool": [331, 332, 333, 334, 335, 336, 337, 338, 339, 340]
        },
        {
          "subtopic": "Scientific Notation Word Problems",
          "subtopic_id": 15,
          "reading": {
            "title": "Applying Scientific Notation in Word Problems",
            "content": "Scientific notation is used in real-world applications like astronomy and chemistry. For example, if the distance from Earth to the Sun is 1.5 × 10^8 km, and a spaceship travels at 3 × 10^4 km per hour, time to reach the Sun is (1.5 × 10^8) ÷ (3 × 10^4) = 5 × 10^3 hours."
          },
          "quizPool": [341, 342, 343, 344, 345, 346, 347, 348, 349, 350]
        }

      ]
    },
    {
      "unit": "Solving Equations with One Unknown",
      "unit_id": 2,
      "subtopics": [
        {
          "subtopic": "Equations with Variables on Both Sides",
          "subtopic_id": 7,
          "reading": {
            "title": "Solving Equations with Variables on Both Sides",
            "content": "### What Are Equations with Variables on Both Sides?\nThese equations have **the unknown variable (x, y, etc.) on both sides** of the equal sign.\n\n### General Form:\n- **ax + b = cx + d**\n\n### Steps to Solve:\n1. **Move all variable terms to one side** (use addition or subtraction).\n2. **Move constant terms to the other side**.\n3. **Simplify** and **solve for the variable**.\n\n### Example:\nSolve **3x + 2 = 5x - 4**\n1. Subtract **3x** from both sides → **2 = 2x - 4**\n2. Add **4** to both sides → **6 = 2x**\n3. Divide by **2** → **x = 3**\n\n### Special Cases:\n- **No solution**: If variables cancel and you get a false statement (e.g., **2 = 5**).\n- **Infinite solutions**: If variables cancel and you get a true statement (e.g., **4 = 4**).\n\n### Applications:\n- **Finance**: Comparing two salary offers.\n- **Engineering**: Calculating force balances.\n- **Physics**: Analyzing motion equations."
          },
          "quizPool": [261, 262, 263, 264, 265, 266, 267, 268, 269, 270]
        },
        {
          "subtopic": "Equations with Parentheses",
          "subtopic_id": 8,
          "reading": {
            "title": "Expanding and Solving Equations with Parentheses",
            "content": "Equations containing parentheses require distribution before solving. Example: 2(x + 3) = 10 -> Distribute: 2x + 6 = 10 -> Subtract 6: 2x = 4 -> Divide by 2: x = 2."
          },
          "quizPool": [271, 272, 273, 274, 275, 276, 277, 278, 279, 280]
        },
        {
          "subtopic": "Number of Solutions to Equations",
          "subtopic_id": 9,
          "reading": {
            "title": "Understanding the Number of Solutions to Equations",
            "content": "### How Many Solutions Can an Equation Have?\nEquations can have **one solution, no solution, or infinitely many solutions**.\n\n### 1. One Solution:\n- The equation simplifies to **x = a single number**.\n- Example: **2x + 3 = 9** → x = **3**\n\n### 2. No Solution:\n- The equation simplifies to a **false statement**.\n- Example: **3x + 2 = 3x - 4** → 2 = -4 (which is false, so no solution!)\n\n### 3. Infinitely Many Solutions:\n- The equation simplifies to a **true statement**.\n- Example: **4x + 8 = 4(x + 2)** → 4x + 8 = 4x + 8 (always true)\n\n### Identifying Solutions Easily:\n| **Equation Type**      | **What Happens?**        | **Solution Count** |\n|------------------|------------------|---------------|\n| 2x + 3 = 9       | Solve for x      | **One**       |\n| 5x - 4 = 5x + 6  | Variables cancel, false equation | **No solution** |\n| 3(x - 2) = 3x - 6 | Variables cancel, true equation | **Infinite** |\n\n### Applications:\n- **Physics**: Checking if an equation has a valid physical solution.\n- **Engineering**: Solving force and stress equations.\n- **Computer Science**: Debugging equations in algorithms."
          },
          "quizPool": [281, 282, 283, 284, 285, 286, 287, 288, 289, 290]
        },
        {
          "subtopic": "Equations Word Problems",
          "subtopic_id": 16,
          "reading": {
            "title": "Solving Word Problems Using Equations",
            "content": "### What Are Word Problems with Equations?\nWord problems require **translating real-world scenarios** into algebraic equations before solving.\n\n### Steps to Solve:\n1. **Define the variable** (what are we solving for?).\n2. **Write an equation** based on the problem description.\n3. **Solve for the unknown**.\n4. **Check if the answer makes sense**.\n\n### Example 1 (Age Problem):\n- Jake is twice as old as Sam. Together, they are 18 years old.\n- Define Sam’s age as **x** → Jake’s age is **2x**.\n- Write the equation: **x + 2x = 18**\n- Solve: **3x = 18**, so **x = 6** (Sam is 6, Jake is 12).\n\n### Example 2 (Money Problem):\n- A movie ticket costs\$6 for children and \$10 for adults.\n- If the total revenue was **\$300**, and 20 child tickets were sold, how many adult tickets were sold?\n- Define **x = number of adult tickets**.\n- Equation: **6(20) + 10x = 300**\n- Solve: **120 + 10x = 300** → **10x = 180** → **x = 18**\n\n### Applications:\n- **Finance**: Budgeting problems.\n- **Business**: Profit and loss calculations.\n- **Engineering**: Material usage calculations.\n\nMastering word problems helps in **real-world problem-solving and critical thinking**."
          },
          "quizPool": [351, 352, 353, 354, 355, 356, 357, 358, 359, 360]
        }
      ]
    },
    {
      "unit": "Linear Equations and Functions",
      "unit_id": 3,
      "subtopics": [
        {
          "subtopic": "Equations with Variables on Both Sides",
          "subtopic_id": 7,
          "reading": {
            "title": "Solving Equations with Variables on Both Sides",
            "content": "### What Are Equations with Variables on Both Sides?\nThese equations have **the unknown variable (x, y, etc.) on both sides** of the equal sign.\n\n### General Form:\n- **ax + b = cx + d**\n\n### Steps to Solve:\n1. **Move all variable terms to one side** (use addition or subtraction).\n2. **Move constant terms to the other side**.\n3. **Simplify** and **solve for the variable**.\n\n### Example:\nSolve **3x + 2 = 5x - 4**\n1. Subtract **3x** from both sides → **2 = 2x - 4**\n2. Add **4** to both sides → **6 = 2x**\n3. Divide by **2** → **x = 3**\n\n### Special Cases:\n- **No solution**: If variables cancel and you get a false statement (e.g., **2 = 5**).\n- **Infinite solutions**: If variables cancel and you get a true statement (e.g., **4 = 4**).\n\n### Applications:\n- **Finance**: Comparing two salary offers.\n- **Engineering**: Calculating force balances.\n- **Physics**: Analyzing motion equations."
          },
          "quizPool": [261, 262, 263, 264, 265, 266, 267, 268, 269, 270]
        },
        {
          "subtopic": "Equations with Parentheses",
          "subtopic_id": 8,
          "reading": {
            "title": "Expanding and Solving Equations with Parentheses",
            "content": "Equations containing parentheses require distribution before solving. Example: 2(x + 3) = 10 -> Distribute: 2x + 6 = 10 -> Subtract 6: 2x = 4 -> Divide by 2: x = 2."
          },
          "quizPool": [271, 272, 273, 274, 275, 276, 277, 278, 279, 280]
        },
        {
          "subtopic": "Number of Solutions to Equations",
          "subtopic_id": 9,
          "reading": {
            "title": "Understanding the Number of Solutions to Equations",
            "content": "### How Many Solutions Can an Equation Have?\nEquations can have **one solution, no solution, or infinitely many solutions**.\n\n### 1. One Solution:\n- The equation simplifies to **x = a single number**.\n- Example: **2x + 3 = 9** → x = **3**\n\n### 2. No Solution:\n- The equation simplifies to a **false statement**.\n- Example: **3x + 2 = 3x - 4** → 2 = -4 (which is false, so no solution!)\n\n### 3. Infinitely Many Solutions:\n- The equation simplifies to a **true statement**.\n- Example: **4x + 8 = 4(x + 2)** → 4x + 8 = 4x + 8 (always true)\n\n### Identifying Solutions Easily:\n| **Equation Type**      | **What Happens?**        | **Solution Count** |\n|------------------|------------------|---------------|\n| 2x + 3 = 9       | Solve for x      | **One**       |\n| 5x - 4 = 5x + 6  | Variables cancel, false equation | **No solution** |\n| 3(x - 2) = 3x - 6 | Variables cancel, true equation | **Infinite** |\n\n### Applications:\n- **Physics**: Checking if an equation has a valid physical solution.\n- **Engineering**: Solving force and stress equations.\n- **Computer Science**: Debugging equations in algorithms."
          },
          "quizPool": [281, 282, 283, 284, 285, 286, 287, 288, 289, 290]
        },
        {
          "subtopic": "Equations Word Problems",
          "subtopic_id": 16,
          "reading": {
            "title": "Solving Word Problems Using Equations",
            "content": "### What Are Word Problems with Equations?\nWord problems require **translating real-world scenarios** into algebraic equations before solving.\n\n### Steps to Solve:\n1. **Define the variable** (what are we solving for?).\n2. **Write an equation** based on the problem description.\n3. **Solve for the unknown**.\n4. **Check if the answer makes sense**.\n\n### Example 1 (Age Problem):\n- Jake is twice as old as Sam. Together, they are 18 years old.\n- Define Sam’s age as **x** → Jake’s age is **2x**.\n- Write the equation: **x + 2x = 18**\n- Solve: **3x = 18**, so **x = 6** (Sam is 6, Jake is 12).\n\n### Example 2 (Money Problem):\n- A movie ticket costs\$6 for children and \$10 for adults.\n- If the total revenue was **\$300**, and 20 child tickets were sold, how many adult tickets were sold?\n- Define **x = number of adult tickets**.\n- Equation: **6(20) + 10x = 300**\n- Solve: **120 + 10x = 300** → **10x = 180** → **x = 18**\n\n### Applications:\n- **Finance**: Budgeting problems.\n- **Business**: Profit and loss calculations.\n- **Engineering**: Material usage calculations.\n\nMastering word problems helps in **real-world problem-solving and critical thinking**."
          },
          "quizPool": [351, 352, 353, 354, 355, 356, 357, 358, 359, 360]
        }
      ]
    },
    {
      "unit": "Systems of Equations",
      "unit_id": 4,
      "subtopics": [
        {
          "subtopic": "Equations with Variables on Both Sides",
          "subtopic_id": 7,
          "reading": {
            "title": "Solving Equations with Variables on Both Sides",
            "content": "### What Are Equations with Variables on Both Sides?\nThese equations have **the unknown variable (x, y, etc.) on both sides** of the equal sign.\n\n### General Form:\n- **ax + b = cx + d**\n\n### Steps to Solve:\n1. **Move all variable terms to one side** (use addition or subtraction).\n2. **Move constant terms to the other side**.\n3. **Simplify** and **solve for the variable**.\n\n### Example:\nSolve **3x + 2 = 5x - 4**\n1. Subtract **3x** from both sides → **2 = 2x - 4**\n2. Add **4** to both sides → **6 = 2x**\n3. Divide by **2** → **x = 3**\n\n### Special Cases:\n- **No solution**: If variables cancel and you get a false statement (e.g., **2 = 5**).\n- **Infinite solutions**: If variables cancel and you get a true statement (e.g., **4 = 4**).\n\n### Applications:\n- **Finance**: Comparing two salary offers.\n- **Engineering**: Calculating force balances.\n- **Physics**: Analyzing motion equations."
          },
          "quizPool": [261, 262, 263, 264, 265, 266, 267, 268, 269, 270]
        },
        {
          "subtopic": "Equations with Parentheses",
          "subtopic_id": 8,
          "reading": {
            "title": "Expanding and Solving Equations with Parentheses",
            "content": "Equations containing parentheses require distribution before solving. Example: 2(x + 3) = 10 -> Distribute: 2x + 6 = 10 -> Subtract 6: 2x = 4 -> Divide by 2: x = 2."
          },
          "quizPool": [271, 272, 273, 274, 275, 276, 277, 278, 279, 280]
        },
        {
          "subtopic": "Number of Solutions to Equations",
          "subtopic_id": 9,
          "reading": {
            "title": "Understanding the Number of Solutions to Equations",
            "content": "### How Many Solutions Can an Equation Have?\nEquations can have **one solution, no solution, or infinitely many solutions**.\n\n### 1. One Solution:\n- The equation simplifies to **x = a single number**.\n- Example: **2x + 3 = 9** → x = **3**\n\n### 2. No Solution:\n- The equation simplifies to a **false statement**.\n- Example: **3x + 2 = 3x - 4** → 2 = -4 (which is false, so no solution!)\n\n### 3. Infinitely Many Solutions:\n- The equation simplifies to a **true statement**.\n- Example: **4x + 8 = 4(x + 2)** → 4x + 8 = 4x + 8 (always true)\n\n### Identifying Solutions Easily:\n| **Equation Type**      | **What Happens?**        | **Solution Count** |\n|------------------|------------------|---------------|\n| 2x + 3 = 9       | Solve for x      | **One**       |\n| 5x - 4 = 5x + 6  | Variables cancel, false equation | **No solution** |\n| 3(x - 2) = 3x - 6 | Variables cancel, true equation | **Infinite** |\n\n### Applications:\n- **Physics**: Checking if an equation has a valid physical solution.\n- **Engineering**: Solving force and stress equations.\n- **Computer Science**: Debugging equations in algorithms."
          },
          "quizPool": [281, 282, 283, 284, 285, 286, 287, 288, 289, 290]
        },
        {
          "subtopic": "Equations Word Problems",
          "subtopic_id": 16,
          "reading": {
            "title": "Solving Word Problems Using Equations",
            "content": "### What Are Word Problems with Equations?\nWord problems require **translating real-world scenarios** into algebraic equations before solving.\n\n### Steps to Solve:\n1. **Define the variable** (what are we solving for?).\n2. **Write an equation** based on the problem description.\n3. **Solve for the unknown**.\n4. **Check if the answer makes sense**.\n\n### Example 1 (Age Problem):\n- Jake is twice as old as Sam. Together, they are 18 years old.\n- Define Sam’s age as **x** → Jake’s age is **2x**.\n- Write the equation: **x + 2x = 18**\n- Solve: **3x = 18**, so **x = 6** (Sam is 6, Jake is 12).\n\n### Example 2 (Money Problem):\n- A movie ticket costs\$6 for children and \$10 for adults.\n- If the total revenue was **\$300**, and 20 child tickets were sold, how many adult tickets were sold?\n- Define **x = number of adult tickets**.\n- Equation: **6(20) + 10x = 300**\n- Solve: **120 + 10x = 300** → **10x = 180** → **x = 18**\n\n### Applications:\n- **Finance**: Budgeting problems.\n- **Business**: Profit and loss calculations.\n- **Engineering**: Material usage calculations.\n\nMastering word problems helps in **real-world problem-solving and critical thinking**."
          },
          "quizPool": [351, 352, 353, 354, 355, 356, 357, 358, 359, 360]
        }
      ]
    },
    {
      "unit": "Geometry",
      "unit_id": 5,
      "subtopics": [
        {
          "subtopic": "Equations with Variables on Both Sides",
          "subtopic_id": 7,
          "reading": {
            "title": "Solving Equations with Variables on Both Sides",
            "content": "### What Are Equations with Variables on Both Sides?\nThese equations have **the unknown variable (x, y, etc.) on both sides** of the equal sign.\n\n### General Form:\n- **ax + b = cx + d**\n\n### Steps to Solve:\n1. **Move all variable terms to one side** (use addition or subtraction).\n2. **Move constant terms to the other side**.\n3. **Simplify** and **solve for the variable**.\n\n### Example:\nSolve **3x + 2 = 5x - 4**\n1. Subtract **3x** from both sides → **2 = 2x - 4**\n2. Add **4** to both sides → **6 = 2x**\n3. Divide by **2** → **x = 3**\n\n### Special Cases:\n- **No solution**: If variables cancel and you get a false statement (e.g., **2 = 5**).\n- **Infinite solutions**: If variables cancel and you get a true statement (e.g., **4 = 4**).\n\n### Applications:\n- **Finance**: Comparing two salary offers.\n- **Engineering**: Calculating force balances.\n- **Physics**: Analyzing motion equations."
          },
          "quizPool": [261, 262, 263, 264, 265, 266, 267, 268, 269, 270]
        },
        {
          "subtopic": "Equations with Parentheses",
          "subtopic_id": 8,
          "reading": {
            "title": "Expanding and Solving Equations with Parentheses",
            "content": "Equations containing parentheses require distribution before solving. Example: 2(x + 3) = 10 -> Distribute: 2x + 6 = 10 -> Subtract 6: 2x = 4 -> Divide by 2: x = 2."
          },
          "quizPool": [271, 272, 273, 274, 275, 276, 277, 278, 279, 280]
        },
        {
          "subtopic": "Number of Solutions to Equations",
          "subtopic_id": 9,
          "reading": {
            "title": "Understanding the Number of Solutions to Equations",
            "content": "### How Many Solutions Can an Equation Have?\nEquations can have **one solution, no solution, or infinitely many solutions**.\n\n### 1. One Solution:\n- The equation simplifies to **x = a single number**.\n- Example: **2x + 3 = 9** → x = **3**\n\n### 2. No Solution:\n- The equation simplifies to a **false statement**.\n- Example: **3x + 2 = 3x - 4** → 2 = -4 (which is false, so no solution!)\n\n### 3. Infinitely Many Solutions:\n- The equation simplifies to a **true statement**.\n- Example: **4x + 8 = 4(x + 2)** → 4x + 8 = 4x + 8 (always true)\n\n### Identifying Solutions Easily:\n| **Equation Type**      | **What Happens?**        | **Solution Count** |\n|------------------|------------------|---------------|\n| 2x + 3 = 9       | Solve for x      | **One**       |\n| 5x - 4 = 5x + 6  | Variables cancel, false equation | **No solution** |\n| 3(x - 2) = 3x - 6 | Variables cancel, true equation | **Infinite** |\n\n### Applications:\n- **Physics**: Checking if an equation has a valid physical solution.\n- **Engineering**: Solving force and stress equations.\n- **Computer Science**: Debugging equations in algorithms."
          },
          "quizPool": [281, 282, 283, 284, 285, 286, 287, 288, 289, 290]
        },
        {
          "subtopic": "Equations Word Problems",
          "subtopic_id": 16,
          "reading": {
            "title": "Solving Word Problems Using Equations",
            "content": "### What Are Word Problems with Equations?\nWord problems require **translating real-world scenarios** into algebraic equations before solving.\n\n### Steps to Solve:\n1. **Define the variable** (what are we solving for?).\n2. **Write an equation** based on the problem description.\n3. **Solve for the unknown**.\n4. **Check if the answer makes sense**.\n\n### Example 1 (Age Problem):\n- Jake is twice as old as Sam. Together, they are 18 years old.\n- Define Sam’s age as **x** → Jake’s age is **2x**.\n- Write the equation: **x + 2x = 18**\n- Solve: **3x = 18**, so **x = 6** (Sam is 6, Jake is 12).\n\n### Example 2 (Money Problem):\n- A movie ticket costs\$6 for children and \$10 for adults.\n- If the total revenue was **\$300**, and 20 child tickets were sold, how many adult tickets were sold?\n- Define **x = number of adult tickets**.\n- Equation: **6(20) + 10x = 300**\n- Solve: **120 + 10x = 300** → **10x = 180** → **x = 18**\n\n### Applications:\n- **Finance**: Budgeting problems.\n- **Business**: Profit and loss calculations.\n- **Engineering**: Material usage calculations.\n\nMastering word problems helps in **real-world problem-solving and critical thinking**."
          },
          "quizPool": [351, 352, 353, 354, 355, 356, 357, 358, 359, 360]
        }
      ]
    },
    {
      "unit": "Geometric Transformations",
      "unit_id": 6,
      "subtopics": [
        {
          "subtopic": "Equations with Variables on Both Sides",
          "subtopic_id": 7,
          "reading": {
            "title": "Solving Equations with Variables on Both Sides",
            "content": "### What Are Equations with Variables on Both Sides?\nThese equations have **the unknown variable (x, y, etc.) on both sides** of the equal sign.\n\n### General Form:\n- **ax + b = cx + d**\n\n### Steps to Solve:\n1. **Move all variable terms to one side** (use addition or subtraction).\n2. **Move constant terms to the other side**.\n3. **Simplify** and **solve for the variable**.\n\n### Example:\nSolve **3x + 2 = 5x - 4**\n1. Subtract **3x** from both sides → **2 = 2x - 4**\n2. Add **4** to both sides → **6 = 2x**\n3. Divide by **2** → **x = 3**\n\n### Special Cases:\n- **No solution**: If variables cancel and you get a false statement (e.g., **2 = 5**).\n- **Infinite solutions**: If variables cancel and you get a true statement (e.g., **4 = 4**).\n\n### Applications:\n- **Finance**: Comparing two salary offers.\n- **Engineering**: Calculating force balances.\n- **Physics**: Analyzing motion equations."
          },
          "quizPool": [261, 262, 263, 264, 265, 266, 267, 268, 269, 270]
        },
        {
          "subtopic": "Equations with Parentheses",
          "subtopic_id": 8,
          "reading": {
            "title": "Expanding and Solving Equations with Parentheses",
            "content": "Equations containing parentheses require distribution before solving. Example: 2(x + 3) = 10 -> Distribute: 2x + 6 = 10 -> Subtract 6: 2x = 4 -> Divide by 2: x = 2."
          },
          "quizPool": [271, 272, 273, 274, 275, 276, 277, 278, 279, 280]
        },
        {
          "subtopic": "Number of Solutions to Equations",
          "subtopic_id": 9,
          "reading": {
            "title": "Understanding the Number of Solutions to Equations",
            "content": "### How Many Solutions Can an Equation Have?\nEquations can have **one solution, no solution, or infinitely many solutions**.\n\n### 1. One Solution:\n- The equation simplifies to **x = a single number**.\n- Example: **2x + 3 = 9** → x = **3**\n\n### 2. No Solution:\n- The equation simplifies to a **false statement**.\n- Example: **3x + 2 = 3x - 4** → 2 = -4 (which is false, so no solution!)\n\n### 3. Infinitely Many Solutions:\n- The equation simplifies to a **true statement**.\n- Example: **4x + 8 = 4(x + 2)** → 4x + 8 = 4x + 8 (always true)\n\n### Identifying Solutions Easily:\n| **Equation Type**      | **What Happens?**        | **Solution Count** |\n|------------------|------------------|---------------|\n| 2x + 3 = 9       | Solve for x      | **One**       |\n| 5x - 4 = 5x + 6  | Variables cancel, false equation | **No solution** |\n| 3(x - 2) = 3x - 6 | Variables cancel, true equation | **Infinite** |\n\n### Applications:\n- **Physics**: Checking if an equation has a valid physical solution.\n- **Engineering**: Solving force and stress equations.\n- **Computer Science**: Debugging equations in algorithms."
          },
          "quizPool": [281, 282, 283, 284, 285, 286, 287, 288, 289, 290]
        },
        {
          "subtopic": "Equations Word Problems",
          "subtopic_id": 16,
          "reading": {
            "title": "Solving Word Problems Using Equations",
            "content": "### What Are Word Problems with Equations?\nWord problems require **translating real-world scenarios** into algebraic equations before solving.\n\n### Steps to Solve:\n1. **Define the variable** (what are we solving for?).\n2. **Write an equation** based on the problem description.\n3. **Solve for the unknown**.\n4. **Check if the answer makes sense**.\n\n### Example 1 (Age Problem):\n- Jake is twice as old as Sam. Together, they are 18 years old.\n- Define Sam’s age as **x** → Jake’s age is **2x**.\n- Write the equation: **x + 2x = 18**\n- Solve: **3x = 18**, so **x = 6** (Sam is 6, Jake is 12).\n\n### Example 2 (Money Problem):\n- A movie ticket costs\$6 for children and \$10 for adults.\n- If the total revenue was **\$300**, and 20 child tickets were sold, how many adult tickets were sold?\n- Define **x = number of adult tickets**.\n- Equation: **6(20) + 10x = 300**\n- Solve: **120 + 10x = 300** → **10x = 180** → **x = 18**\n\n### Applications:\n- **Finance**: Budgeting problems.\n- **Business**: Profit and loss calculations.\n- **Engineering**: Material usage calculations.\n\nMastering word problems helps in **real-world problem-solving and critical thinking**."
          },
          "quizPool": [351, 352, 353, 354, 355, 356, 357, 358, 359, 360]
        }
      ]
    },
    {
      "unit": "Data and Modeling",
      "unit_id": 7,
      "subtopics": [
        {
          "subtopic": "Equations with Variables on Both Sides",
          "subtopic_id": 7,
          "reading": {
            "title": "Solving Equations with Variables on Both Sides",
            "content": "### What Are Equations with Variables on Both Sides?\nThese equations have **the unknown variable (x, y, etc.) on both sides** of the equal sign.\n\n### General Form:\n- **ax + b = cx + d**\n\n### Steps to Solve:\n1. **Move all variable terms to one side** (use addition or subtraction).\n2. **Move constant terms to the other side**.\n3. **Simplify** and **solve for the variable**.\n\n### Example:\nSolve **3x + 2 = 5x - 4**\n1. Subtract **3x** from both sides → **2 = 2x - 4**\n2. Add **4** to both sides → **6 = 2x**\n3. Divide by **2** → **x = 3**\n\n### Special Cases:\n- **No solution**: If variables cancel and you get a false statement (e.g., **2 = 5**).\n- **Infinite solutions**: If variables cancel and you get a true statement (e.g., **4 = 4**).\n\n### Applications:\n- **Finance**: Comparing two salary offers.\n- **Engineering**: Calculating force balances.\n- **Physics**: Analyzing motion equations."
          },
          "quizPool": [261, 262, 263, 264, 265, 266, 267, 268, 269, 270]
        },
        {
          "subtopic": "Equations with Parentheses",
          "subtopic_id": 8,
          "reading": {
            "title": "Expanding and Solving Equations with Parentheses",
            "content": "Equations containing parentheses require distribution before solving. Example: 2(x + 3) = 10 -> Distribute: 2x + 6 = 10 -> Subtract 6: 2x = 4 -> Divide by 2: x = 2."
          },
          "quizPool": [271, 272, 273, 274, 275, 276, 277, 278, 279, 280]
        },
        {
          "subtopic": "Number of Solutions to Equations",
          "subtopic_id": 9,
          "reading": {
            "title": "Understanding the Number of Solutions to Equations",
            "content": "### How Many Solutions Can an Equation Have?\nEquations can have **one solution, no solution, or infinitely many solutions**.\n\n### 1. One Solution:\n- The equation simplifies to **x = a single number**.\n- Example: **2x + 3 = 9** → x = **3**\n\n### 2. No Solution:\n- The equation simplifies to a **false statement**.\n- Example: **3x + 2 = 3x - 4** → 2 = -4 (which is false, so no solution!)\n\n### 3. Infinitely Many Solutions:\n- The equation simplifies to a **true statement**.\n- Example: **4x + 8 = 4(x + 2)** → 4x + 8 = 4x + 8 (always true)\n\n### Identifying Solutions Easily:\n| **Equation Type**      | **What Happens?**        | **Solution Count** |\n|------------------|------------------|---------------|\n| 2x + 3 = 9       | Solve for x      | **One**       |\n| 5x - 4 = 5x + 6  | Variables cancel, false equation | **No solution** |\n| 3(x - 2) = 3x - 6 | Variables cancel, true equation | **Infinite** |\n\n### Applications:\n- **Physics**: Checking if an equation has a valid physical solution.\n- **Engineering**: Solving force and stress equations.\n- **Computer Science**: Debugging equations in algorithms."
          },
          "quizPool": [281, 282, 283, 284, 285, 286, 287, 288, 289, 290]
        },
        {
          "subtopic": "Equations Word Problems",
          "subtopic_id": 16,
          "reading": {
            "title": "Solving Word Problems Using Equations",
            "content": "### What Are Word Problems with Equations?\nWord problems require **translating real-world scenarios** into algebraic equations before solving.\n\n### Steps to Solve:\n1. **Define the variable** (what are we solving for?).\n2. **Write an equation** based on the problem description.\n3. **Solve for the unknown**.\n4. **Check if the answer makes sense**.\n\n### Example 1 (Age Problem):\n- Jake is twice as old as Sam. Together, they are 18 years old.\n- Define Sam’s age as **x** → Jake’s age is **2x**.\n- Write the equation: **x + 2x = 18**\n- Solve: **3x = 18**, so **x = 6** (Sam is 6, Jake is 12).\n\n### Example 2 (Money Problem):\n- A movie ticket costs\$6 for children and \$10 for adults.\n- If the total revenue was **\$300**, and 20 child tickets were sold, how many adult tickets were sold?\n- Define **x = number of adult tickets**.\n- Equation: **6(20) + 10x = 300**\n- Solve: **120 + 10x = 300** → **10x = 180** → **x = 18**\n\n### Applications:\n- **Finance**: Budgeting problems.\n- **Business**: Profit and loss calculations.\n- **Engineering**: Material usage calculations.\n\nMastering word problems helps in **real-world problem-solving and critical thinking**."
          },
          "quizPool": [351, 352, 353, 354, 355, 356, 357, 358, 359, 360]
        }
      ]
    }];

  @override
  State<PathwayUI> createState() => _PathwayUIState();
}

class _PathwayUIState extends State<PathwayUI> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Learning Pathway'),
      ),
      body: ListView(
        children: [
          PathwayStep(
            title: 'Step 1: Basics',
            isCompleted: true,
          ),
          PathwayStep(
            title: 'Step 2: Intermediate',
            isCompleted: true,
          ),
          PathwayStep(
            title: 'Step 3: Advanced',
            isCompleted: false,
          ),
        ],
      ),
    );
  }
}

class PathwayStep extends StatelessWidget {
  final String title;
  final bool isCompleted;

  PathwayStep({required this.title, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green[100] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Colors.green : Colors.grey,
          ),
          SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isCompleted ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
