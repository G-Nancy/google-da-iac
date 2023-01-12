CREATE TABLE logs(
UUID String(64) NOT NULL,
Timestamp TIMESTAMP NOT NULL OPTIONS (allow_commit_timestamp=true),
customerNumber INT64 NOT NULL,
status String(64) NOT NULL,
source String(64) NOT NULL
) PRIMARY KEY(UUID)