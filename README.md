# 🛒 Olist E-Commerce Analytics Pipeline

An end-to-end data analytics pipeline built on AWS that ingests, transforms, and visualizes 100,000+ real e-commerce orders from the [Olist Brazil dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce). The project simulates the full workflow of a data/product analyst — from raw data ingestion to business insights and interactive dashboards.

---

## 📊 Live Dashboard

👉 **[View Live Dashboard](https://vedikaaa23.github.io/olist-ecommerce-analytics/ecommerce_analytics_pipeline.html)**
---

## 🏗️ Architecture

```
Raw CSV Data (Kaggle Olist)
        │
        ▼
┌──────────────┐
│   AWS S3     │  ← Raw data lake (9 CSV files uploaded)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  AWS Glue    │  ← ETL: clean nulls, join tables, output Parquet
└──────┬───────┘
       │
       ▼
┌──────────────┐
│AWS Redshift  │  ← Data warehouse: SQL analytics layer
└──────┬───────┘
       │
       ▼
┌──────────────┐
│ QuickSight   │  ← Dashboards: KPIs, funnels, cohorts, RFM
└──────────────┘
```

---

## 🛠️ Tech Stack

| Layer | Service | Purpose |
|-------|---------|---------|
| Storage | AWS S3 | Raw data lake — stores original CSV files |
| ETL | AWS Glue | Cleans, joins, and transforms raw data into Parquet |
| Warehouse | AWS Redshift | Columnar data warehouse for SQL analytics |
| BI / Viz | AWS QuickSight | Interactive dashboards and business reporting |
| Query Engine | AWS Athena | Ad-hoc serverless SQL queries directly on S3 |
| Language | SQL | KPIs, cohorts, funnels, window functions, CTEs |
| Language | Python | Data simulation and Glue ETL scripting |

---

## 📁 Project Structure

```
olist-ecommerce-analytics/
│
├── ecommerce_analytics_pipeline.html   ← Interactive dashboard (open in browser)
├── README.md                           ← This file
│
└── sql/
    ├── 01_revenue_kpis.sql             ← Monthly revenue, orders, AOV
    ├── 02_cohort_retention.sql         ← Cohort retention % by signup month
    ├── 03_funnel_analysis.sql          ← Drop-off at each funnel step
    ├── 04_rfm_segmentation.sql         ← RFM customer segments using NTILE
    └── 05_top_products.sql             ← Top categories by revenue + rank
```

---

## 📈 Key Business Insights

### 1. 🔴 93% of customers never repurchase
Month-1 retention across all cohorts averaged only **4–5%**, revealing the business is heavily acquisition-driven with weak loyalty. Recommendation: implement a post-purchase email sequence targeting the "Potential Loyalist" RFM segment.

### 2. 🔴 30% cart-to-checkout drop-off
Funnel analysis revealed a significant drop between users who added items to cart and those who started checkout. Recommendation: A/B test checkout UX — reduce form fields, add trust signals, offer saved payment methods.

### 3. 🟢 November 2017 = peak revenue month
Revenue spiked to **$892K** in November 2017 (Black Friday effect) — 21% above the monthly average. Recommendation: invest in pre-event targeted campaigns 3–4 weeks before peak periods.

### 4. 🟡 Bed & Bath is the top revenue category
With **$2.34M** in total revenue across the period, Bed & Bath leads all categories. Health & Beauty and Sports follow. Recommendation: prioritise inventory and promotions for these top 3 categories.

### 5. 🟡 8,412 Champion customers drive outsized revenue
RFM segmentation identified Champions (highest recency + frequency) averaging **$412 per order** vs $98 for new customers. Recommendation: create a VIP programme for Champions with early access and exclusive offers.

---

## 🗄️ SQL Highlights

### Cohort Retention (CTEs + DATE_TRUNC)
```sql
WITH first_purchase AS (
  SELECT customer_id,
    MIN(DATE_TRUNC('month', order_purchase)) AS cohort_month
  FROM orders
  WHERE order_status = 'delivered'
  GROUP BY customer_id
)
SELECT cohort_month,
  COUNT(DISTINCT customer_id) AS cohort_size
FROM first_purchase
GROUP BY 1
ORDER BY 1;
```

### RFM Segmentation (Window Functions + NTILE)
```sql
SELECT *,
  NTILE(5) OVER (ORDER BY recency  DESC) AS r_score,
  NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
  NTILE(5) OVER (ORDER BY monetary  ASC) AS m_score
FROM rfm_base;
```

### Funnel Analysis (Conditional Aggregation)
```sql
SELECT
  COUNT(DISTINCT CASE WHEN step='signup'   THEN user_id END) AS signup,
  COUNT(DISTINCT CASE WHEN step='purchase' THEN user_id END) AS purchase,
  ROUND(COUNT(DISTINCT CASE WHEN step='purchase' THEN user_id END) * 100.0
      / COUNT(DISTINCT CASE WHEN step='signup' THEN user_id END), 1) AS conversion_pct
FROM events;
```

Full queries are in the [`sql/`](./sql/) folder.

---

## 🚀 How to Run This Project

### Option A — View the dashboard instantly (no setup)
1. Download `ecommerce_analytics_pipeline.html`
2. Double-click to open in your browser
3. The dashboard loads with all data and charts immediately

### Option B — Deploy on AWS (full pipeline)

#### Prerequisites
- AWS account (free tier is sufficient)
- Kaggle account to download the dataset

#### Step 1 — Download the dataset
Download the [Olist Brazilian E-Commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) from Kaggle. It contains 9 CSV files.

#### Step 2 — Upload to S3
```
1. Create an S3 bucket: olist-data-raw
2. Upload all 9 CSV files
3. Organise into folders: /orders, /customers, /products, /order_items
```

#### Step 3 — Run AWS Glue ETL
```
1. Create a Glue Crawler pointing to your S3 bucket
2. Run the crawler to auto-detect schema
3. Create a Glue ETL job to join tables and output Parquet
4. Run the job — output lands in a new S3 folder: olist-data-processed/
```

#### Step 4 — Load into Redshift
```sql
-- Create tables (see sql/ folder for full schema)
CREATE TABLE orders (
  order_id       VARCHAR(50) PRIMARY KEY,
  customer_id    VARCHAR(50),
  order_status   VARCHAR(20),
  order_purchase TIMESTAMP
);

-- Load from S3
COPY orders
FROM 's3://olist-data-raw/orders/olist_orders_dataset.csv'
IAM_ROLE 'arn:aws:iam::YOUR_ACCOUNT_ID:role/RedshiftS3Role'
CSV IGNOREHEADER 1;
```

#### Step 5 — Connect QuickSight
```
1. Open AWS QuickSight → New Dataset → Redshift
2. Connect using your Redshift endpoint and credentials
3. Import the KPI views as datasets
4. Build visuals: line chart (revenue), pie (categories), table (RFM)
5. Publish dashboard
```

---

## 💰 AWS Cost

This entire project can be built for **$0** using AWS Free Tier:

| Service | Free Tier Allowance |
|---------|-------------------|
| S3 | 5 GB storage free |
| Glue | 10 DPU-hours/month free |
| Redshift Serverless | 300 RPU-hours free trial |
| Athena | ~$0 for small datasets |
| QuickSight | 30-day free trial |

---

## 📚 Dataset

**Olist Brazilian E-Commerce** — publicly available on Kaggle

- 100,000 orders from 2016–2018
- 9 related tables: orders, order items, customers, products, sellers, payments, reviews, geolocation, product category translations
- Real anonymised data from Brazilian marketplace

🔗 [Download from Kaggle](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

---

## 🎯 Skills Demonstrated

`AWS S3` `AWS Glue` `Amazon Redshift` `Amazon QuickSight` `AWS Athena`  
`SQL` `Window Functions` `CTEs` `Cohort Analysis` `Funnel Analysis`  
`RFM Segmentation` `ETL Pipelines` `Data Warehousing` `Python` `Data Storytelling`

---

## 👤 Author

**Vedika Singh**  
📧 vedikasingh780@gmail.com  
🔗 [https://www.linkedin.com/in/vedika-singh-5616aa215/](https://linkedin.com/in/your-profile)  
🐙 [https://github.com/Vedikaaa23](https://github.com/YOUR-USERNAME)

---

*Built as a portfolio project to demonstrate end-to-end data analytics skills for Product Analyst / Data Analyst roles.*
