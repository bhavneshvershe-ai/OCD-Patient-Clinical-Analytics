-- Creating the Database & Table Schema

create database if not exists ocd_db;
use ocd_db;

create table ocd_patients 
( patient_id INT PRIMARY KEY, 
age INT, gender VARCHAR(10), 
ethnicity VARCHAR(50), 
marital_status VARCHAR(30), 
education_level VARCHAR(30), 
ocd_diagnosis_date DATE, 
duration_of_symptoms_months INT, 
previous_diagnoses VARCHAR(50), 
family_history_of_ocd VARCHAR(10), 
obsession_type VARCHAR(50), 
compulsion_type VARCHAR(50), 
ybocs_score_obsessions INT, 
ybocs_score_compulsions INT, 
depression_diagnosis VARCHAR(10), 
anxiety_diagnosis VARCHAR(10), 
medications VARCHAR(50) );

-- Verification Query
select count(*) as total_patients from ocd_patients;

-- Data Cleansing & NULL Auditing

select sum(case when previous_diagnoses is null then 1 else 0 end) 
as missing_prev_diagnoses,
sum(case when medications is null then 1 else 0 end)
as missing_meds from ocd_patients;

-- Q1: Count total patients in the clinical study.

select count(*) as total_patients
from ocd_patients;

-- Q2: Find the gender breakdown of OCD patients.

select gender, count(*) as patient_count 
from ocd_patients
group by gender ;

-- Q3: Calculate average age of patients across genders.

select gender ,avg(age) 
from ocd_patients
group by gender;

-- Q4: Find the most common obsession type.

select obsession_type , count(*) as total_cases 
from ocd_patients
group by obsession_type
order by total_cases desc ;

-- Q5: Find the Most Common Compulsion Type.

select compulsion_type , count(*) as total_case 
from ocd_patients
group by compulsion_type 
order by total_case desc ;


-- Q6: Average Y-BOCS Obsession & Compulsion Scores.
 
 select avg(ybocs_score_obsessions) as AVG_obsessions_score,
 avg (ybocs_score_compulsions) as AVG_compulsions_score 
 from ocd_patients;
 
 
 -- Q7: Count Patients with Comorbid Depression and Anxiety

select  count(*) as Comorbid_Depression 
from ocd_patients
where depression_diagnosis = 'Yes' and anxiety_diagnosis = 'Yes';


-- Q8: Find average Y-BOCS total score by ethnicity.

select ethnicity,round (avg(ybocs_score_obsessions + ybocs_score_compulsions),2) as avg_total_scoure
from ocd_patients
group by ethnicity
order by avg_total_scoure desc;


-- Q9: Family History of OCD vs. Severity.

select family_history_of_ocd, count(*) as patient_count,
round (avg (ybocs_score_obsessions + ybocs_score_compulsions),2)as avg_ybocs
from ocd_patients
group by family_history_of_ocd ;


-- Q10: Top Prescribed Pharmaceutical Medications. 

select medications , count(*) as top_medication 
from ocd_patients 
group by medications
order by top_medication  desc ;


-- Q11: Average Duration of Symptoms by Marital Status

select marital_status, round(avg(duration_of_symptoms_months),1) as avg_duration 
from ocd_patients
group by marital_status
order by avg_duration desc ;


-- Q12: Ranking Patients by Severity via DENSE_RANK() 

select patient_id, age, gender, 
(ybocs_score_obsessions + ybocs_score_compulsions) 
as total_ybocs, 
dense_rank() over (order by (ybocs_score_obsessions + ybocs_score_compulsions) 
desc) as severity_rank
from ocd_patients;


-- Q13: Patients Exceeding Cohort Average Y-BOCS Score.

select patient_id, age, gender, (ybocs_score_obsessions + ybocs_score_compulsions) as total_scor 
from ocd_patients 
where  (ybocs_score_obsessions + ybocs_score_compulsions) > ( select avg(ybocs_score_obsessions + ybocs_score_compulsions) 
from ocd_patients );


-- Q14: Cumulative Patient Counts by Diagnosis Year.

with yearly_diag as ( select year(ocd_diagnosis_date) as  diag_year, count(*) as new_patients 
from ocd_patients group by year (ocd_diagnosis_date) ) 
select diag_year, new_patients, sum(new_patients)
over ( order by diag_year Asc Rows Between Unbounded Preceding And Current Row ) as cumulative_patients from yearly_diag;


-- Q15: Categorizing Patient Severity via CASE WHEN.

select patient_id, (ybocs_score_obsessions + ybocs_score_compulsions) as total_ybocs, 
case when (ybocs_score_obsessions + ybocs_score_compulsions) > 30 then 'Severe' 
when (ybocs_score_obsessions + ybocs_score_compulsions) >= 20 
then 'Moderate' else 'Mild' end as clinical_severity 
from ocd_patients;



