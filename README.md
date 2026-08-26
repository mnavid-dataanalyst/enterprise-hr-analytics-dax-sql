# 📊 Nexora HR: Enterprise Workforce Intelligence & Analytics Platform

An end-to-end Business Intelligence solution that models, analyzes, and visualizes workforce metrics across **10,000+ localized synthetic employee records**. Built using T-SQL, a custom star schema data architecture, and narrative-driven Power BI dashboards.

![Dashboard Overview](./visuals/01_executive_overview.png) *(Replace with your primary dashboard image path)*

---

## 📌 Executive Summary & Case Study Highlights

Modern HR leaders often struggle with **cognitive overload**—having massive volumes of data without actionable narrative. This project overhauls an enterprise workforce dataset to eliminate report friction and enable rapid C-suite decision-making.

### Key Problems Solved
* **Cognitive Friction Reduced**: Converted generic visual titles (e.g., *"Average Net Salary by Year"*) into active, insight-first headlines (e.g., *"Finance Leads Corporate Absenteeism Risk with a Peak Score of 4.0"*).
* **DAX Metric Engineering**: Resolved raw unformatted decimal outputs (displaying proper percentages) and implemented protective `IF(ISBLANK())` / `COALESCE()` measures to cleanly populate zeroes during missing historical trend gaps (2019–2023).
* **Export Canvas Standardization**: Standardized custom visual canvases to a uniform 16:9 widescreen layout to prevent black letterboxing artifacts during executive PDF exports.

---

## 📈 Quantifiable Outcomes & Business Impact

| Focus Area | Identified Trend / Operational Insight | Strategic Leadership Impact |
| :--- | :--- | :--- |
| **Talent Mobility** | Digital Marketing and Client Success outpaced other teams in career progression velocity. | High-performer retention budgets realigned to protect fast-growth functions. |
| **Attendance Risk** | Finance flagged high absenteeism risk while overall scheduled shift fulfillment maintained a steady 95.03%. | Targeted corporate wellness interventions deployed to clear operational bottlenecks. |
| **Attrition Finance** | Software Engineering drove an outsized **$23M annual drain** in hard turnover losses. | Technical leadership revised onboarding tracks to mitigate engineering flight risk. |
| **Compensation Audit** | Basic fixed salaries consumed 73.97% of global budget, with the Dhaka hub leading regional costs at 40.35%. | Geographic distribution risks mitigated during fiscal planning. |

---

## 🏗️ Data Architecture & Star Schema Model

The core database (**Nexora_HR**) is engineered using a high-performance **Star Schema** to optimize query performance and facilitate seamless integration with Power BI.

* **Database Engine**: Microsoft SQL Server / T-SQL
* **Fact Tables**: `FactAttendance`, `FactPayroll`, `FactPerformance`, `FactTraining`, `FactLeave`, `FactOvertime`, `FactEmployeeSurvey`, `FactPromotion`, `FactExit`, `FactRecruitment`
* **Dimension Tables**: `DimEmployee`, `DimDepartment`, `DimJob`, `DimLocation`, `DimRecruitmentSource`, `DimTraining`, `DimExitReason`, `DimPerformanceRating`, `DimDate`
* **Data Scale**: 10,000 synthetic records spanning 2019–2026 across 11 business units.

---

## 📁 Repository Structure

```text
├── 📂 visuals
│   ├── 01_executive_overview.png
│   ├── 04.Talent_Mobility.png
│   └── ... (15 dashboard page screenshots)
├── Nexora_HR_Analytics_Dashboard.pbix     # Primary Power BI report file
├── Nexora_HR_Setup.sql                    # Full T-SQL schema creation & data seeding engine
└── README.md                              # Core project documentation
