-- Exploratory Data Analysis (EDA)
SELECT * 
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

# The timeframe for the analysis of approximately 3 years, march 2020 to march 2023
# Basically the timeframe of the COVID-19 Pandemic
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;


# 116 Companies Completely Shutdown 
# The most affected industries by complete shutdowns were Finance (12), Retail (13) and Food (13)
SELECT industry, Count(*) 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
GROUP BY industry
ORDER BY 2 desc;

# The industries with the most total layoff employees were consumer and retail 
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

# Amazon had the most layoffs with over 18k employees, followed by Google, Meta, Salesforce, Microsoft and Philips (each between 10k-12k) total.
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;

# The US had by far the most layoffs with over 256k, followed by India with almost 36k
# This suggests the dataset is heavily influenced by the US job market
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

# Layoff trends show: 81k in 2020, slight decrease to ~16k in 2021, then a sharp increase to 160k+ in 2022, followed by 125k+ in 2023 (only 3 months of data)
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

# This query shows a rolling total of layoffs by month
# The worst months were at the end of 2022 and beginning of 2023
# In contrast to 2021's relatively low total of under 20k layoffs, January 2023 had the worst single month with nearly 85k layoffs
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

# This query ranks the top 5 companies by number of layoffs per year
# Shows which companies had the highest layoffs in each year

# The data reveals a shift in layoff leadership across years
# 2020: US-based companies dominated (Uber, Booking.com, Groupon, Airbnb)
# 2021: Bytedance (TikTok) emerged as a major player with 3,600 layoffs, top 1
# 2022: Meta and Amazon led with over 10,000 layoffs each
# 2023: Google led with 12,000 layoffs, showing continued tech sector impact

SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY company
;


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



