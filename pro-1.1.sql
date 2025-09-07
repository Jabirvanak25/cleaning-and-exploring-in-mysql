select *
from layoffs;

-- REMOVE DUPLICATES

-- another table for cleaning
CREATE TABLE layoffs_2
SELECT * 
FROM layoffs;

SELECT * 
FROM layoffs_2;

select trim(company) ,trim(location) , trim(industry) , trim(country) 
from layoffs_2;

select * ,
row_number() over(partition by company , location , industry , total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
from layoffs_2;

-- GONNA HELP US FIND DUPLICATES
with cte as
(
	select * ,
	row_number() over
    (partition by company , location , industry , total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
	from layoffs_2
)
select * 
from cte 
where row_num >1;

-- THIS IS NOT HOW WE DELETE
with cte as
(
	select * ,
	row_number() over
    (partition by company , location , industry , total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
	from layoffs_2
)
delete 
from cte 
where row_num >1;


-- a table to add column which GONNA HELP US REMOVE DUPLICATES
CREATE TABLE `layoffs_3` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL ,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoffs_3;

insert into layoffs_3
	select * ,
	row_number() over
    (partition by company , location , industry , total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions) as row_num
	from layoffs_2 ;
    
delete 
from layoffs_3
where row_num >1;

select *
from layoffs_3
where row_num>1;

-- STANDARDIZING DATA
SELECT *
FROM layoffs_3;

SELECT distinct INDUSTRY
FROM layoffs_3
ORDER BY 1;

UPDATE layoffs_3
SET INDUSTRY='CRYPTO'
WHERE INDUSTRY LIKE 'CRYPTO%';

-- NOW WE DONT NEED ROW_NUM AS ALREADY DELETED DUPLICATES
ALTER TABLE layoffs_3
DROP COLUMN ROW_NUM;

-- DELETE NULL OR BLANK ROWS FROM TOTAL_LAID_OFF AND PERCENTAGE_LAID_OFF

SELECT *
FROM layoffs_3
WHERE (total_laid_off IS NULL OR total_laid_off LIKE '')
AND (percentage_laid_off IS NULL OR percentage_laid_ofF LIKE '');

DELETE
FROM layoffs_3
WHERE (total_laid_off IS NULL OR total_laid_off LIKE '')
AND (percentage_laid_off IS NULL OR percentage_laid_ofF LIKE '');

SELECT DISTINCT COUNTRY
FROM layoffs_3
ORDER BY 1;

UPDATE layoffs_3
SET  COUNTRY ='United States' 
WHERE COUNTRY LIKE 'UNITED%';

update layoffs_3
set `date`=str_to_date(`date`,'%m/%d/%Y');

alter table layoffs_3
modify column `date` date;


-- MAKE SURE TO CONVERT EVERY EMPTY VALUES TO NULL 
select *
from layoffs_3
where funds_raised_millions is null or '';

UPDATE layoffs_3
SET INDUSTRY = NULL 
WHERE INDUSTRY = '';