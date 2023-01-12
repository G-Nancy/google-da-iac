SELECT
customer_name,
customer_birth_date,
country
FROM `${project}.${dataset}.${cr_table}`
WHERE
account_type = 'saving'