-- File: models/mart/invalid_uuid.sql
-- Description: Create a table or model with columns uuid and created_date

CREATE TABLE invalid_uuid AS
SELECT
  'iruinwopdnwnde'::VARCHAR AS uuid,
  '2026-05-01'::DATE AS created_date;