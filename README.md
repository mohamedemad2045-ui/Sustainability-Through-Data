# 🌍 **Sustainability-Through-Data**

> Sustainable development integrates environmental responsibility, economic stability, and social equity.  
> By leveraging data, we evaluate impact, monitor progress, and guide strategies that ensure a balanced and lasting future.

<div align="center">
<img src="https://github.com/mohamedemad2045-ui/Sustainability-Through-Data/blob/main/Python/Project_logo.png?raw=true" width="400"/>
</div>

An end-to-end **data analysis** Final Project showcasing our work in analyzing **Global Climate Events and their Economic Impact**.  
This project was developed for **DEPI Round 4 (2025–2026)**, using real-world climate disaster data to deliver **actionable insights**.

---

## 👥 **Data Analysis Team Members**

✨ Mohamed Emad *(Team Leader)*  
✨ Ahmed Bahaa  
✨ Shaimaa AbdulRahman  
✨ Amaal Ayman  
✨ Bassant Abd El-Hakim

---

## 🏗 **Project Structure**

```plaintext
📦 Sustainability-Through-Data/
├── 📂 Data source/       → Raw dataset (Kaggle — Global Climate Events)
├── 📂 Excel/             → Data cleaning, pivot tables, KPI dashboard
├── 📂 Final Presentation/→ Final project presentation slides
├── 📂 Power BI/          → Interactive dashboards (.pbix)
├── 📂 Project Documentation/ → Full project documentation report
├── 📂 Python/            → EDA, preprocessing, visualizations
├── 📂 SQL/               → Database schema design and queries
├── 📂 Tableau/           → Dashboards and stories (.twb/.twbx)
└── README.md             → Project documentation
```

---

## 📊 **Project Overview**

The **Global Climate Events Economic Impact** project is a cross-functional data analytics initiative designed to uncover **the economic and human consequences of worldwide climate disasters between 2020 and 2025**.

Using a real-world dataset sourced from Kaggle, we walk through the complete data pipeline:  
✅ Data Cleaning → ✅ Data Modeling → ✅ KPI Generation → ✅ Visualization → ✅ Business Recommendations

### 🎯 Key Performance Indicators (KPIs)
| KPI | Description |
|-----|-------------|
| **Total Events** | Count of all recorded climate events |
| **Total Deaths** | Sum of fatalities across all events |
| **Total Economic Impact** | Aggregate economic loss (millions USD) |
| **Average Severity** | Mean severity score (1–10 scale) |
| **Average Response Time** | Mean emergency response time (hours) |

---

## 🛠 **Tools & Technologies**

| 🛠 Tool | 🔍 Purpose |
|--------|-----------|
| **SQL** | Database modeling, star schema design, querying & aggregations |
| **Python** | EDA, statistical analysis, feature analysis, visualizations |
| **Excel** | Data cleaning, filtering, pivot tables, KPI dashboard |
| **Power BI** | Interactive dashboard creation, DAX measures, storytelling |
| **Tableau** | Insight communication, advanced visuals, dashboards |

---

## 🧪 **Methodology**

- 🔹 **Data Cleaning** → Handled missing values, corrected data types, removed duplicates across all 5 tools  
- 🔹 **Data Modeling** → Built a star schema:
  - 1️⃣ Fact Table → `fact_global_climate_events`
  - 6️⃣ Dimensions → `dim_date`, `dim_location`, `dim_event_type`, `dim_severity`, `dim_response_time`, `dim_infrastructure_damage`
- 🔹 **Exploratory Data Analysis (EDA)** → Used Python & Excel to uncover seasonal trends, geographic patterns, and severity correlations  
- 🔹 **KPI Generation** → Calculated Total Events, Total Deaths, Economic Impact, Avg Severity, Avg Response Time  
- 🔹 **Dashboards** → Created actionable, multi-page interactive dashboards with filters by country, event type, severity, and season

---

## 🔍 **Key Insights**

- 📌 Climate events remained **consistently high** across the 2020–2025 period with no downward trend  
- ☀️ **Summer** recorded the highest event severity scores and casualty counts  
- 🍂 **Autumn** generated the highest total economic impact  
- ⚡ **Faster emergency response** is associated with lower casualty rates  
- 💸 International aid covered only **~0.48%** of total recorded economic losses  
- 🌐 The **United States, India, China, Japan, and Portugal** recorded the highest climate event counts

---

## 📂 **How to Use**

1️⃣ **Clone the Repository**
```bash
git clone https://github.com/mohamedemad2045-ui/Sustainability-Through-Data.git
```

2️⃣ **Explore Excel Files**  
Open `.xlsx` files in the `Excel/` folder for raw data, pivot tables, and KPI dashboard.

3️⃣ **Run Python Notebooks**  
Ensure you have the required libraries:
```bash
pip install pandas matplotlib seaborn plotly
```
Then open the notebooks inside the `Python/` folder.

4️⃣ **Open Dashboards**
- Power BI → `.pbix` files in `Power BI/`
- Tableau → `.twbx` or `.twb` files in `Tableau/`

5️⃣ **Run SQL Scripts**  
Open the scripts in the `SQL/` folder using **MySQL 8.0** or any compatible SQL environment.

⚠️ **Important:** Some file paths may need adjustment depending on your local setup.

---

## 🌟 **Project Highlights**

✨ **Multi-Tool Implementation**  
Every stage of the analysis — from data cleaning to dashboard delivery — was implemented independently across **5 analytical platforms**, validating consistency and showcasing versatility.

✨ **Real-World Impact Focus**  
The project directly addresses **UN Sustainable Development Goals** by quantifying climate disaster impacts and recommending data-driven policy actions.

✨ **Cross-Functional Collaboration**  
The team successfully divided responsibilities across SQL/Python analysis and BI dashboard development, delivering a cohesive, professional-grade final product.

---

## 📄 **Dataset**

- **Source:** [Kaggle — Global Climate Events Dataset]([https://www.kaggle.com](https://www.kaggle.com/datasets/uom190346a/global-climate-events-and-economic-impact-dataset/data))  
- **Coverage:** 2020–2025 | Global | 51 countries  
- **Records:** ~3,000 climate event records  
- **Key Fields:** Event Type, Country, Continent, Season, Severity, Deaths, Injuries, Economic Impact (M USD), Response Time (hrs), International Aid (M USD)

---

*Developed as part of DEPI Round 4 (2025–2026) — Data Analyst Specialist Track*
