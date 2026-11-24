use job_market_db;

select *from job_postings
LIMIT 10;

-- Cột salary_hour_avg đang là varchar(100) với các giá trị như $39,80 hoặc $61,16. Hãy làm sạch ký tự $, đổi dấu phẩy thập phân , thành ., ép sang kiểu số (DECIMAL(10,2)) và tính mức lương theo giờ trung bình theo job_country.
SELECT
    job_country,
    COUNT(*) AS hourly_jobs,
    ROUND(
        AVG(
            CAST(
                REPLACE(REPLACE(TRIM(salary_hour_avg), '$', ''), ',', '.')
                AS DECIMAL(10, 2)
            )
        ),
        2
    ) AS avg_hourly_rate
FROM job_postings
WHERE salary_hour_avg IS NOT NULL
  AND TRIM(salary_hour_avg) != ''
  AND LOWER(TRIM(salary_hour_avg)) != '(null)'
GROUP BY job_country
ORDER BY avg_hourly_rate DESC;

-- Vị trí nào có mức lương trung bình năm cao nhất?
Select job_title_short,
count(*) as total_jobs,
round(avg(salary_year_avg), 2) as average_salary,
round(MIN(salary_year_avg), 2) as min_salary,
round(MAX(salary_year_avg), 2) as max_salary
from job_postings
where salary_year_avg is not null and TRIM(salary_year_avg) <> ''
group by job_title_short
order by average_salary desc;


-- Phân loại các tin tuyển dụng có lương theo các nhóm mức lương (Thấp / Trung bình / Cao) để xem phân bổ thị trường?
SELECT 
    CASE 
        WHEN salary_year_avg < 70000 THEN 'Under $70k'
        WHEN salary_year_avg BETWEEN 70000 AND 120000 THEN '$70k - $120k'
        ELSE 'Above $120k'
    END AS salary_group,
    COUNT(*) AS total_jobs,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS share_pct
FROM job_postings
WHERE salary_year_avg IS NOT NULL 
  AND salary_year_avg > 0
GROUP BY salary_group
ORDER BY total_jobs DESC;

-- Tìm các kênh đăng tuyển (job_via) có ít nhất 10 tin làm việc từ xa (job_work_from_home = 1), hiển thị số lượng tin WFH, tổng số tin của kênh đó, và tỷ lệ WFH trên kênh.
SELECT
    job_via,
    SUM(CASE WHEN job_work_from_home = 1 THEN 1 ELSE 0 END) AS wfh_jobs,
    COUNT(*) AS total_jobs,
    ROUND(
        SUM(CASE WHEN job_work_from_home = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS wfh_share_pct
FROM job_postings
WHERE job_via IS NOT NULL
GROUP BY job_via
HAVING wfh_jobs >= 10
ORDER BY wfh_jobs DESC, wfh_share_pct DESC;

-- Tìm Top 10 công ty đăng nhiều tin nhất ở mỗi quốc gia (job_country), hiển thị cả thứ hạng (rank_in_country).
WITH company_country_counts AS (
    SELECT
        job_country,
        company_name,
        COUNT(*) AS job_count,
        DENSE_RANK() OVER (
            PARTITION BY job_country
            ORDER BY COUNT(*) DESC
        ) AS rank_in_country
    FROM job_postings
    WHERE job_country IS NOT NULL
      AND company_name IS NOT NULL
      AND TRIM(company_name) != ''
    GROUP BY job_country, company_name
)
SELECT
    job_country,
    company_name,
    job_count,
    rank_in_country
FROM company_country_counts
WHERE rank_in_country <= 10
ORDER BY job_country, rank_in_country, job_count DESC;


-- Dùng job_posted_date sau khi parse ngày để xem nhà tuyển dụng đăng tin nhiều nhất vào thứ mấy trong tuần.
WITH parsed_dates AS (
    SELECT
        STR_TO_DATE(TRIM(job_posted_date), '%d/%m/%y %H:%i') AS posted_dt
    FROM job_postings
    WHERE job_posted_date IS NOT NULL
      AND TRIM(job_posted_date) != ''
)
SELECT
    DAYNAME(posted_dt) AS weekday_name,
    DAYOFWEEK(posted_dt) AS weekday_num,
    COUNT(*) AS total_postings
FROM parsed_dates
WHERE posted_dt IS NOT NULL
GROUP BY weekday_name, weekday_num
ORDER BY weekday_num;

-- Tỷ lệ tin đăng yêu cầu SQL và Python theo từng chức danh (job_title_short)
WITH skill_demand AS (
    SELECT
        job_title_short,
        CASE WHEN LOWER(COALESCE(job_skills, '')) LIKE '%sql%' THEN 1 ELSE 0 END AS requires_sql,
        CASE WHEN LOWER(COALESCE(job_skills, '')) LIKE '%python%' THEN 1 ELSE 0 END AS requires_python
    FROM job_postings
    WHERE job_title_short IS NOT NULL
      AND TRIM(job_title_short) != ''
)
SELECT
    job_title_short,
    COUNT(*) AS total_jobs,
    SUM(requires_sql) AS sql_jobs,
    ROUND(SUM(requires_sql) * 100.0 / COUNT(*), 2) AS sql_pct,
    SUM(requires_python) AS python_jobs,
    ROUND(SUM(requires_python) * 100.0 / COUNT(*), 2) AS python_pct
FROM skill_demand
GROUP BY job_title_short
ORDER BY sql_pct DESC, python_pct DESC;