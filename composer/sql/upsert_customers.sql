MERGE {{ params.customer_history_table }} H
USING {{ params.customer_staging_table }} U
ON H.id = U.id
WHEN MATCHED THEN
  UPDATE SET first_name = U.first_name, last_name=U.last_name, date_of_birth=U.date_of_birth, address=U.address
WHEN NOT MATCHED THEN
  INSERT (id, first_name, last_name, date_of_birth, address) VALUES(id, first_name, last_name, date_of_birth, address)