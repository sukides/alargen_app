-- Add group_name / category fields for granular allergen classification
ALTER TABLE facts ALTER COLUMN category TYPE VARCHAR(50);
ALTER TABLE facts ADD COLUMN IF NOT EXISTS group_name VARCHAR(100);
ALTER TABLE rules ADD COLUMN IF NOT EXISTS category VARCHAR(100);
