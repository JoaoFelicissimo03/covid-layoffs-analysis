## COVID Layoffs Analysis (SQL)

### Project Overview

This project analyzes global company layoffs during the COVID-19 period (2020–2023) using SQL.
It focuses on data cleaning, exploratory data analysis (EDA), and trend analysis to identify patterns across time, industries, countries, and companies.

The project applies real-world analytical techniques such as window functions, CTEs, and time-series comparisons to generate meaningful insights.
---

### Tools Used

* SQL
* GitHub
* PowerBi (Next Step)

---

### Dataset

* **File:** `layoffs.csv`
* **Source:** Kaggle
   [Dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022)
* **Description:**
  The dataset contains information about company layoffs, including company name, industry, country, date, and number of employees laid off.

---

### Project Files

#### `layoffs.csv`
Raw dataset used for the analysis.

#### `DC_CovidLayoffs.sql`
Data cleaning script, including:
- Removing duplicate records
- Handling missing values
- Standardizing text fields
- Formatting date columns
- Preparing staging tables

#### `EDA_CovidLayoffs.sql`
Exploratory data analysis script, including:
- Rolling and cumulative trends
- Industry impact and recovery analysis
- Volatility and stability classification
  
##### Key Analysis Areas:
- **Time-Based Trends**
- **Industry Analysis**
- **Country Comparison**
- **Company Analysis**

---

### Limitations

- Company workforce size is not available, limiting proportional impact analysis
- Financial performance data is not included
- Results are based on publicly reported layoff records

All company-level interpretations are made with these constraints in mind.

---

### Key Objectives

- Apply structured SQL analysis to a real-world dataset
- Practice data cleaning and validation techniques
- Use CTEs and window functions for trend analysis
- Develop analytical storytelling skills
- Build a professional data analytics portfolio project

---

### Future Improvements

- Data visualization using Power BI
- Interactive dashboard development
- Predictive modeling of layoff trends
- Analysis of impacts of layoffs in some companies.

---

### Author

Developed by: **João Felicíssimo**  
Aspiring Data Analyst


