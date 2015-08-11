CREATE OR REPLACE VIEW aggregated_searchables AS
 SELECT
	entity_id AS searchable_id,
	entity_type,
	field_name,
	LOWER(translations.string) AS str
 FROM
  translations
UNION
  SELECT
    id AS searchable_id,
    'Physician' AS entity_type,
    'name' AS field_name,
    LOWER(physicians.name) AS str
  FROM
    physicians
UNION
  SELECT
    id AS searchable_id,
    'Physician' AS entity_type,
    'position' AS field_name,
    LOWER(physicians.position) AS str
  FROM
    physicians
UNION
  SELECT
    id AS searchable_id,
    'Symptom' AS entity_type,
    'name' AS field_name,
    LOWER(symptoms.name) AS str
  FROM
    symptoms
UNION
  SELECT
    id AS searchable_id,
    'Condition' AS entity_type,
    'name' AS field_name,
    LOWER(conditions.name) AS str
  FROM
    conditions
UNION
  SELECT
    id AS searchable_id,
    'Hospital' AS entity_type,
    'name' AS field_name,
    LOWER(hospitals.name) AS str
  FROM
    hospitals
UNION
  SELECT
    id AS searchable_id,
    'Department' AS entity_type,
    'name' AS field_name,
    LOWER(departments.name) AS str
  FROM
    departments
;
