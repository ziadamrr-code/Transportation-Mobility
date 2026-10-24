# 🚖 Goodcabs Analytics: Operations, Passenger Loyalty & Target Performance

> End-to-end analytics project for **Goodcabs**, a ride-hailing company operating in 10 Indian tier-2 cities. Built with **SQL Server (T-SQL)** and a **3-page Power BI dashboard**, based on the [Codebasics Resume Project Challenge](https://codebasics.io/challenges/codebasics-resume-project-challenge/16).

![Power BI](https://img.shields.io/badge/Power%20BI-Dashboard-F2C811?logo=powerbi&logoColor=black)
![SQL Server](https://img.shields.io/badge/SQL%20Server-T--SQL-CC2927?logo=microsoftsqlserver&logoColor=white)

---

## 📌 Table of Contents

1. [Business Context](#-business-context)
2. [Business Questions](#-business-questions)
3. [Tech Stack](#-tech-stack)
4. [Data Model](#-data-model)
5. [Methodology & Assumptions](#-methodology--assumptions)
6. [Dashboard Overview](#-dashboard-overview)
7. [Key Insights](#-key-insights)
8. [Recommendations](#-recommendations)
9. [Repository Structure](#-repository-structure)
10. [How to Reproduce](#-how-to-reproduce)
11. [Author](#-author)

---

## 🏢 Business Context

Goodcabs is a ride-hailing startup focused on **tier-2 cities in India**, with a mission to provide reliable, affordable and driver-friendly transportation. After its first six months of operation (**January–June 2024**), management needed a data-backed view of:

- How each city performs against its **monthly targets** (trips, new passengers, passenger ratings).
- How well the company **retains passengers** (repeat passenger behaviour).
- Where demand **peaks and dips**, and how **weekday vs. weekend** patterns differ.

---

## ❓ Business Questions

The dashboard answers the 8 primary questions of the challenge:

| # | Question | Dashboard Page |
|---|----------|----------------|
| Q1 | Top and bottom 3 cities by total trips | 1 – Operations & Revenue |
| Q2 | Average fare per trip vs. average trip distance by city | 1 – Operations & Revenue |
| Q3 | Average ratings by city and passenger type (new / repeat) | 2 – Passengers & Loyalty |
| Q4 | Peak and low demand month for each city | 1 – Operations & Revenue |
| Q5 | Weekday vs. weekend share of trips by city | 1 – Operations & Revenue |
| Q6 | Repeat passenger trip frequency distribution | 2 – Passengers & Loyalty |
| Q7 | Performance vs. targets (trips, new passengers, ratings) | 3 – Target Performance |
| Q8 | Repeat Passenger Rate (RPR%) by city and month | 2 – Passengers & Loyalty |

---

## 🛠 Tech Stack

| Layer | Tool | Purpose |
|-------|------|---------|
| Data preparation | **SQL Server (T-SQL)** | Targets database, data exploration and queries (SELECT, JOIN) |
| Modeling | **Power BI** (Import mode) | Star-schema relationships |
| Calculations | **DAX** | KPIs, ratios, target comparisons |
| Visualization | **Power BI Desktop** | Interactive 3-page report |

---

## 🗂 Data Model

The Power BI model follows a **star schema**:

**Fact tables**
- `fact_trips`: trip-level data (fare, distance, passenger type, ratings)
- `fact_passenger_summary`: monthly passenger counts per city (total, new, repeat)
- `dim_repeat_trip_distribution`: repeat-passenger counts by number of trips taken

**Dimensions**
- `dim_city`: city details, plus calculated columns **City Type**, **City Lat**, **City Lon** (used for the map)
- `dim_date`: calendar with `day_type` (Weekday / Weekend)
- `dim_month`: month hierarchy

**Target tables** (stored in `targets_db`, 130 rows total)

| Table | Columns | Rows |
|-------|---------|------|
| `city_target_passenger_rating` | `city_id` (PK), `target_avg_passenger_rating` | 10 |
| `monthly_target_new_passengers` | `month`, `city_id`, `target_new_passengers` (composite PK) | 60 |
| `monthly_target_trips` | `month`, `city_id`, `total_target_trips` (composite PK) | 60 |

Covered cities (IDs): `AP01, CH01, GJ01, GJ02, KA01, KL01, MP01, RJ01, TN01, UP01`, January–June 2024.

---

## ⚙️ Methodology & Assumptions

1. **SQL layer**: explored and queried the data with T-SQL (see the `sql/` folder).
2. **Targets database**: the original MySQL dump of `targets_db` was converted to T-SQL: `IF DB_ID(...) IS NULL CREATE DATABASE`, `GO` batch separators, `dbo` schema, named primary-key constraints, bracketed `[month]`, and removal of MySQL-specific syntax (backticks, `ENGINE`, `LOCK TABLES`, etc.).
3. **Modeling**: tables imported into Power BI and related through `city_id` and the date/month dimensions.
4. **DAX measures** built for the report:
   - *Core:* Total Trips, Total Fare, Avg Fare per Trip, Avg Fare per Km, Avg Trip Distance
   - *Passengers:* Total Passengers, New Passengers, Repeat Passengers, Repeat Passenger Rate %
   - *Targets:* Trips Target, Trips Achievement %, Trips Diff %, Trips On Target %
   - *Demand (Q4):* Peak Trips, Low Trips, Trip Range
5. **Design**: 3 pages, max 5 KPI cards per page, consistent purple palette, and global slicers for City type, City, Month, Day type and Passenger type.

**Assumptions made**
- **City type** (Tourism vs. Business) is *not* in the source data. It was assigned as an assumption: **Jaipur, Kochi, Mysore, Visakhapatnam = Tourism**; all others = Business.
- **Target status:** *Exceeded* if above **+1%** of target, *Met* within **±1%**, *Missed* below **−1%**.
- **Customer count** on the map = sum of monthly total passengers per city.

---

## 📊 Dashboard Overview

### 1️⃣ Operations & Revenue
![Operations & Revenue](images/page1_operations_revenue.png)

**KPIs:** Total Trips **426K** · Total Fare **108M** · Avg Fare per Trip **254.02** · Avg Fare per Km **13.28** · Avg Trip Distance **19.13 km**

### 2️⃣ Passengers & Loyalty
![Passengers & Loyalty](images/page2_passengers_loyalty.png)

**KPIs:** Total Passengers **238K** · New Passengers **177K** · Repeat Passenger Rate **25.73%** · Repeat Passengers **61K** · Repeated Trips **249K**

### 3️⃣ Target Performance
![Target Performance](images/page3_target_performance.png)

**KPIs:** Trips Achievement **99.28%** · Avg Passenger Rating **7.66** · Repeat Passenger Rate **25.73%** · Trips On Target **51.67%**

---

## 🔍 Key Insights

### Operations & Revenue
- **Demand is concentrated.** Jaipur leads with ~**77K trips**, then Lucknow (~64K) and Surat (~55K); Mysore is lowest (~16K).
- **Volume and fare per trip don't move together.** Jaipur has the highest average fare per trip (~484), while Surat, third in volume, has the lowest (~117).
- **Peak months differ by city.** Jaipur and Lucknow peak in **February**; Kochi, Indore and Mysore in **May**; Surat, Vadodara and Visakhapatnam in **April**. June is the low point for several cities.

### Passengers & Loyalty
- **Retention is the main growth lever.** Only **25.73%** of passengers are repeat riders, yet **61K repeat passengers generated 249K trips**.
- **Large gap between cities.** Surat (**42.63%**), Lucknow (37.12%) and Indore (32.68%) retain best; Mysore (**11.23%**) and Jaipur (17.43%) lag. **Jaipur is the biggest city by trips but among the weakest in retention.**
- **Positive trend.** RPR% rose from **18.68% (Jan)** to **33.47% (May)**, then dipped to 29.76% in June.

### Target Performance
- Overall volume is on target (**99.28%**), but only **51.67%** of results hit their trip targets, so the headline hides city-level misses.
- Cities beating their trip target often miss their rating or new-passenger target (and vice versa).

---

## 💡 Recommendations

1. **Launch loyalty programmes in low-RPR, high-volume cities** (Jaipur, Mysore): ride bundles, repeat-ride discounts, referral credits.
2. **Replicate Surat's and Lucknow's retention playbook** in underperforming cities by identifying what differs operationally.
3. **Plan capacity and promotions per city**, using each city's own peak and trough months.
4. **Review pricing and trip-length strategy in Surat**, where high volume pairs with the lowest fare per trip.
5. **Investigate cities missing rating targets** and link rating drops to repeat-passenger churn.
6. **Set seasonality-aware, city-specific targets** to make "Trips On Target %" a fairer measure.

---

## 📁 Repository Structure

```
Transportation-Mobility/
├── README.md
├── sql/
│   ├── Transportation & Mobility.sql    # exploration queries (SELECT / JOIN)
│   └── targets_db.sql                   # targets database
├── powerbi/
│   └── Goodcabs.pbit                    # Power BI template (no data)
└── images/
    ├── page1_operations_revenue.png
    ├── page2_passengers_loyalty.png
    └── page3_target_performance.png
```

---

## 🚀 How to Reproduce

1. **Clone** the repository:
   ```bash
   git clone https://github.com/ziadamrr-code/Transportation-Mobility.git
   ```
2. In **SQL Server (SSMS)**, run `sql/targets_db.sql` to create `targets_db` and its 3 target tables.
3. Download the trips and passenger datasets from the [challenge page](https://codebasics.io/challenges/codebasics-resume-project-challenge/16) and load them into your own database.
4. Open `powerbi/Goodcabs.pbit` in **Power BI Desktop**, enter your SQL Server connection details when prompted, and click **Refresh**.

---

## 👤 Author

**Ziad Amr Saad Abdelfadel**
💻 [GitHub](https://github.com/ziadamrr-code) · 🔗 [LinkedIn](www.linkedin.com/in/ziadamrr)

---

*Dataset and business scenario provided by the Codebasics Resume Project Challenge. This project is for learning and portfolio purposes.*
