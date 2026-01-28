-- =====================================================
-- Project: COVID-19 Layoffs Exploratory Data Analysis
-- Author: João Felicíssimo
-- Description: Analysis of global layoffs (2020–2023)
-- Tools: MySQL, Window Functions, CTEs
-- Dataset: Kaggle - Layoffs 2022
-- =====================================================

SELECT * 
FROM layoffs_staging2;

-- Steps
-- 1 Time Based Analysis: Overall Layoff Trends
-- 2 Industry Trends
-- 3 Country Comparison
-- 4 Company behavior analysis 








-- =============================================
-- 1 Time-Based Analysis: Overall Layoff Trends
-- =============================================

-- The timeframe for the analysis of approximately 3 years, march 2020 to march 2023
-- This timeframe corresponds to the core period of the COVID-19 pandemic
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;

-- Layoff trends show: 81,000 in 2020, slight decrease to ~16k in 2021, then a sharp increase to 160k+ in 2022, followed by 125k+ in 2023 (only 3 months of data)
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;


-- This CTE ranks months by total layoffs, the best 5 and worst 5.

-- KEY FINDINGS:
-- WORST: Jan 2023 (84,714) - Peak layoffs
-- 2023 Q1 dominates worst months (Jan, Feb) - second wave larger than COVID

-- BEST: 4 of the 5 results in 2021 (22-237 range) - clear recovery period
-- Oct 2021 (22) lowest on record

-- Possible Pattern: COVID = immediate shock (Apr-May 2020), 2023 = prolonged downturn

WITH monthly_layoffs AS (
    SELECT
        SUBSTRING(`date`, 1, 7) AS `month`,
        SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging2
    GROUP BY month
),
ranked_months AS (
    SELECT
        month,
        total_layoffs,
        RANK() OVER (ORDER BY total_layoffs DESC) AS worst_rank,
        RANK() OVER (ORDER BY total_layoffs ASC) AS best_rank
    FROM monthly_layoffs
)
SELECT
    month,
    total_layoffs,
    CASE
        WHEN worst_rank <= 5 THEN 'Worst 5 Months'
        WHEN best_rank <= 5 THEN 'Best 5 Months'
    END AS category
FROM ranked_months
WHERE worst_rank <= 5 OR best_rank <= 5
ORDER BY total_layoffs DESC;




-- This query shows a rolling total of layoffs by month
-- The worst months were at the end of 2022 and beginning of 2023
-- In contrast to 2021's relatively low total of under 20,000 layoffs, January 2023 had the worst single month with nearly 85,000 layoffs
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off) AS Sum_Total_Off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC
)
SELECT `month`, Sum_Total_Off
,SUM(Sum_Total_Off) OVER(ORDER BY `month`) AS rolling_Total
FROM Rolling_Total
ORDER BY `month`
LIMIT 5;

-- This query just serves as a tool for future vizualization, it's the same as the one aboce but sorted buy month and without the limitation of the top 5 months.
WITH Rolling_Total AS
(
SELECT SUBSTRING(`date`,1,7) AS `month`, SUM(total_laid_off) AS Sum_Total_Off
FROM layoffs_staging2
WHERE SUBSTRING(`date`,1,7) IS NOT NULL
GROUP BY `month`
ORDER BY 1 ASC
)
SELECT `month`, Sum_Total_Off
,SUM(Sum_Total_Off) OVER(ORDER BY `month`) AS rolling_Total
FROM Rolling_Total;







-- =================
-- 2 Industry Trends
-- =================

-- The industries with the most total layoff employees were consumer and retail 
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Industry layoffs by year
SELECT
    industry,
    YEAR(`date`) AS year,
    SUM(total_laid_off) AS total_layoffs
FROM layoffs_staging2
WHERE industry IS NOT NULL AND industry NOT LIKE ''
GROUP BY industry, year
ORDER BY industry, year;


-- 116 Companies Completely Shutdown 
-- The most affected industries by complete shutdowns were Finance (12), Retail (13) and Food (13)
SELECT industry, Count(*) 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
GROUP BY industry
ORDER BY 2 desc;

-- Total number of company shutdowns per year by industry
SELECT industry, Count(*), YEAR(`date`) AS year
FROM layoffs_staging2
WHERE percentage_laid_off = 1
GROUP BY industry, year
ORDER BY 2 desc;




-- This analysis evaluates how different industries evolved over time by measuring year-over-year changes in layoffs. 
-- Using window functions, it calculates annual differences and summarizes each industry's average trend and volatility.
-- Industries are then classified as Recovering, Declining, Unstable, or Stagnant based on these metrics.

WITH industry_year AS (
    SELECT
        industry,
        YEAR(`date`) AS year,
        SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging2
    WHERE industry IS NOT NULL AND industry NOT LIKE ''
    GROUP BY industry, year
),
industry_change AS (
    SELECT
        industry,
        year,
        total_layoffs,
        total_layoffs - LAG(total_layoffs) OVER (PARTITION BY industry ORDER BY year) AS yearly_change
    FROM industry_year
),
industry_summary AS (
    SELECT
        industry,
        AVG(yearly_change) AS avg_change,
        ROUND(STDDEV(yearly_change), 2) AS volatility
    FROM industry_change
    WHERE yearly_change IS NOT NULL
    GROUP BY industry
)
SELECT
    industry,
    avg_change,
    volatility,
    CASE
    WHEN avg_change < -2000 AND volatility < 8000 THEN 'Recovering'
    WHEN avg_change > 2000 AND volatility < 8000 THEN 'Declining'
    WHEN volatility >= 8000 THEN 'Unstable'
    ELSE 'Stagnant'
    END AS trend_status

FROM industry_summary
ORDER BY trend_status;








-- =====================
-- 3 Country Comparison 
-- =====================

-- The US had by far the most layoffs with over 256k, followed by India with almost 36k
-- This suggests the dataset is heavily influenced by the US job market, so comparing them against each other may not be the best idea
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;


-- Evolution of the Top 5 countries with the most layoffs by year
WITH top_countries AS (
    SELECT
        country
    FROM layoffs_staging2
    WHERE country IS NOT NULL
    GROUP BY country
    ORDER BY SUM(total_laid_off) DESC
    LIMIT 5
),
country_year AS (
    SELECT
        country,
        YEAR(`date`) AS year,
        SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging2
    WHERE country IN (SELECT country FROM top_countries) 
    GROUP BY country, year
)
SELECT *
FROM country_year
WHERE `year` IS NOT NULL
ORDER BY country, year;



--  This analysis evaluates how layoffs evolved across countries by calculating year-over-year changes and measuring volatility.
-- Based on these metrics, countries are classified as Recovering, Declining, Unstable, or Stagnant to highlight different recovery patterns after COVID.
WITH country_year AS (
    SELECT
        country,
        YEAR(`date`) AS year,
        SUM(total_laid_off) AS total_layoffs
    FROM layoffs_staging2
    WHERE country IS NOT NULL
      AND country NOT LIKE ''
    GROUP BY country, year
),
country_change AS (
    SELECT
        country,
        year,
        total_layoffs,
        total_layoffs - LAG(total_layoffs) OVER (PARTITION BY country ORDER BY year) AS yearly_change
    FROM country_year
),
country_summary AS (
    SELECT
        country,
        ROUND(AVG(yearly_change), 2) AS avg_change,
        ROUND(STDDEV(yearly_change), 2) AS volatility
    FROM country_change
    WHERE yearly_change IS NOT NULL
    GROUP BY country
)
SELECT
    country,
    avg_change,
    volatility,
CASE
    WHEN avg_change < -1000 AND volatility < 6000 THEN 'Recovering'
    WHEN avg_change > 1000 AND volatility < 6000 THEN 'Declining'
    WHEN volatility >= 6000 THEN 'Unstable'
    ELSE 'Stagnant'
END AS trend_status
FROM country_summary
ORDER BY trend_status, avg_change;









-- ====================================
--  4 Company Layoff Behavior Analysis
-- ====================================

-- Amazon had the most layoffs with over 18,000 employees, followed by Google, Meta, Salesforce, Microsoft and Philips (each between 10k-12k) total.
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;


-- Total layoffs and number of layoff events per company
-- Meta, Google, and Microsoft each conducted only one layoff event during this period, all exceeding 10,000 employees.
-- Google recorded the largest single layoff at 12,000.
-- The company with the most layoff events was Loft with 6, followed by Uber, Swiggy and WeWork with 5 each.

SELECT
    company,
    SUM(total_laid_off) AS total_layoffs,
    COUNT(*) AS layoff_events,
    ROUND(AVG(total_laid_off), 0) AS avg_layoffs_per_event
FROM layoffs_staging2
WHERE company IS NOT NULL
GROUP BY company
ORDER BY total_layoffs DESC;


-- Amazon, despite having the most layoffs overall across 3 separate events,  had a maximum single-event layoff of 10,000.
SELECT *
FROM layoffs_staging2
WHERE company = 'Amazon';


-- This query ranks the top 5 companies by number of layoffs per year
-- Shows which companies had the highest layoffs in each year

-- The data reveals a shift in layoff leadership across years
-- 2020: US-based companies dominated (Uber, Booking.com, Groupon, Airbnb)
-- 2021: Bytedance (TikTok) emerged as a major player with 3,600 layoffs, top 1
-- 2022: Meta and Amazon led with over 10,000 layoffs each
-- 2023: Google led with 12,000 layoffs, showing continued tech sector impact

WITH Company_year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_year_rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_year_rank
WHERE  Ranking <= 5
;


-- This analysis evaluates company layoff patterns based on absolute layoff numbers.
-- However, it does not account for company size, total workforce, or financial strength.
-- As a result, large companies may appear highly impacted even when layoffs represent a small proportion of their workforce. 
-- For this reason, these results should be interpreted cautiously and are not used as a primary indicator of company performance.
-- Because of this I won't be making analysing the impact of the layoffs in every single company.

