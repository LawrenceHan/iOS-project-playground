CREATE OR REPLACE VIEW common_searches AS
  SELECT
    departments.id AS searchable_id,
    'Department'::VARCHAR AS entity_type,
    'name'::VARCHAR AS field_name,
    LOWER(translations.content) AS content,
    hospitals.latitude AS latitude,
    hospitals.longitude AS longitude,
    hospitals.h_class AS h_class,
    hospitals.id AS hospital_id,
    departments.id AS department_id,
    NULL::INTEGER AS speciality_id,
    NULL::INTEGER AS medication_id,
    NULL::INTEGER AS physician_id,
    NULL::INTEGER AS user_id
  FROM
    departments
  JOIN
    departments_hospitals ON departments.id = departments_hospitals.department_id
  JOIN
    hospitals ON departments_hospitals.hospital_id = hospitals.id
  JOIN
    translations ON departments.id = translations.entity_id
  WHERE translations.entity_type = 'Department' AND translations.field_name = 'name'
UNION
  SELECT
    departments.id AS searchable_id,
    'Department'::VARCHAR AS entity_type,
    'name'::VARCHAR AS field_name,
    LOWER(departments.name) AS content,
    hospitals.latitude AS latitude,
    hospitals.longitude AS longitude,
    hospitals.h_class AS h_class,
    hospitals.id AS hospital_id,
    departments.id AS department_id,
    NULL::INTEGER AS speciality_id,
    NULL::INTEGER AS medication_id,
    NULL::INTEGER AS physician_id,
    NULL::INTEGER AS user_id
  FROM
    departments
  JOIN
    departments_hospitals ON departments.id = departments_hospitals.department_id
  JOIN
    hospitals ON departments_hospitals.hospital_id = hospitals.id

UNION
  SELECT
    physicians.id AS searchable_id,
    'Physician'::VARCHAR AS entity_type,
    'name'::VARCHAR AS field_name,
    LOWER(translations.content) AS content,
    hospitals.latitude AS latitude,
    hospitals.longitude AS longitude,
    hospitals.h_class AS h_class,
    hospital_id,
    department_id,
    specialities.id AS speciality_id,
    NULL::INTEGER AS medication_id,
    physicians.id AS physician_id,
    NULL::INTEGER AS user_id
  FROM
    physicians
  JOIN
    physicians_specialities ON physicians.id = physicians_specialities.physician_id
  JOIN
    specialities ON specialities.id = physicians_specialities.speciality_id
  JOIN
    hospitals ON physicians.hospital_id = hospitals.id
  JOIN
    translations ON physicians.id = translations.entity_id
  WHERE translations.entity_type = 'Physician' AND translations.field_name = 'name'
UNION
  SELECT
    physicians.id AS searchable_id,
    'Physician'::VARCHAR AS entity_type,
    'name'::VARCHAR AS field_name,
    LOWER(physicians.name) AS content,
    hospitals.latitude AS latitude,
    hospitals.longitude AS longitude,
    hospitals.h_class AS h_class,
    hospital_id,
    department_id,
    specialities.id AS speciality_id,
    NULL::INTEGER AS medication_id,
    physicians.id AS physician_id,
    NULL::INTEGER AS user_id
  FROM
    physicians
  JOIN
    physicians_specialities ON physicians.id = physicians_specialities.physician_id
  JOIN
    specialities ON specialities.id = physicians_specialities.speciality_id
  JOIN
    hospitals ON physicians.hospital_id = hospitals.id

UNION
  SELECT
    health_conditions.id AS searchable_id,
    health_conditions.type AS entity_type,
    'name'::VARCHAR AS field_name,
    LOWER(translations.content) AS content,
    NULL::NUMERIC AS latitude,
    NULL::NUMERIC AS longitude,
    NULL::VARCHAR AS h_class,
    NULL::INTEGER AS hospital_id,
    NULL::INTEGER AS department_id,
    NULL::INTEGER AS speciality_id,
    NULL::INTEGER AS medication_id,
    NULL::INTEGER AS physician_id,
    NULL::INTEGER AS user_id
  FROM
    health_conditions
  JOIN
    translations ON health_conditions.id = translations.entity_id AND translations.entity_type = health_conditions.type
  WHERE
    translations.field_name = 'name'
UNION
  SELECT
    health_conditions.id AS searchable_id,
    health_conditions.type AS entity_type,
    'name'::VARCHAR AS field_name,
    LOWER(health_conditions.name) AS content,
    NULL::NUMERIC AS latitude,
    NULL::NUMERIC AS longitude,
    NULL::VARCHAR AS h_class,
    NULL::INTEGER AS hospital_id,
    NULL::INTEGER AS department_id,
    NULL::INTEGER AS speciality_id,
    NULL::INTEGER AS medication_id,
    NULL::INTEGER AS physician_id,
    NULL::INTEGER AS user_id
  FROM
    health_conditions

UNION
  SELECT
    hospitals.id AS searchable_id,
    'Hospital'::VARCHAR AS entity_type,
    'name'::VARCHAR AS field_name,
    LOWER(translations.content) AS content,
    latitude,
    longitude,
    h_class,
    hospitals.id AS hospital_id,
    NULL::INTEGER AS department_id,
    NULL::INTEGER AS speciality_id,
    NULL::INTEGER AS medication_id,
    NULL::INTEGER AS physician_id,
    NULL::INTEGER AS user_id
  FROM
    hospitals
  JOIN
    translations ON hospitals.id = translations.entity_id
  WHERE
    translations.entity_type = 'Hospital' AND translations.field_name = 'name'
UNION
  SELECT
    hospitals.id AS searchable_id,
    'Hospital'::VARCHAR AS entity_type,
    'name'::VARCHAR AS field_name,
    LOWER(hospitals.name) AS content,
    latitude,
    longitude,
    h_class,
    hospitals.id AS hospital_id,
    NULL::INTEGER AS department_id,
    NULL::INTEGER AS speciality_id,
    NULL::INTEGER AS medication_id,
    NULL::INTEGER AS physician_id,
    NULL::INTEGER AS user_id
  FROM
    hospitals

UNION
  SELECT
    medications.id AS searchable_id,
    'Medication'::VARCHAR AS entity_type,
    'name'::VARCHAR AS field_name,
    LOWER(translations.content) AS content,
    NULL::NUMERIC AS latitude,
    NULL::NUMERIC AS longitude,
    NULL::VARCHAR AS h_class,
    NULL::INTEGER AS hospital_id,
    NULL::INTEGER AS department_id,
    NULL::INTEGER AS speciality_id,
    medications.id AS medication_id,
    NULL::INTEGER AS physician_id,
    NULL::INTEGER AS user_id
  FROM
    medications
  JOIN
    translations ON medications.id = translations.entity_id
  WHERE
    translations.entity_type = 'Medication' AND translations.field_name = 'name'
UNION
  SELECT
    medications.id AS searchable_id,
    'Medication'::VARCHAR AS entity_type,
    'name'::VARCHAR AS field_name,
    LOWER(medications.name) AS content,
    NULL::NUMERIC AS latitude,
    NULL::NUMERIC AS longitude,
    NULL::VARCHAR AS h_class,
    NULL::INTEGER AS hospital_id,
    NULL::INTEGER AS department_id,
    NULL::INTEGER AS speciality_id,
    medications.id AS medication_id,
    NULL::INTEGER AS physician_id,
    NULL::INTEGER AS user_id
  FROM
    medications

UNION
  SELECT
    medications.id AS searchable_id,
    'Medication'::VARCHAR AS entity_type,
    'code'::VARCHAR AS field_name,
    LOWER(translations.content) AS content,
    NULL::NUMERIC AS latitude,
    NULL::NUMERIC AS longitude,
    NULL::VARCHAR AS h_class,
    NULL::INTEGER AS hospital_id,
    NULL::INTEGER AS department_id,
    NULL::INTEGER AS speciality_id,
    medications.id medication_id,
    NULL::INTEGER AS physician_id,
    NULL::INTEGER AS user_id
  FROM
    medications
  JOIN
    translations ON medications.id = translations.entity_id
  WHERE
    translations.entity_type = 'Medication' AND translations.field_name = 'code'
UNION
  SELECT
    medications.id AS searchable_id,
    'Medication'::VARCHAR AS entity_type,
    'code'::VARCHAR AS field_name,
    LOWER(medications.code) AS content,
    NULL::NUMERIC AS latitude,
    NULL::NUMERIC AS longitude,
    NULL::VARCHAR AS h_class,
    NULL::INTEGER AS hospital_id,
    NULL::INTEGER AS department_id,
    NULL::INTEGER AS speciality_id,
    medications.id AS medication_id,
    NULL::INTEGER AS physician_id,
    NULL::INTEGER AS user_id
  FROM
    medications

UNION
  SELECT
    specialities.id AS searchable_id,
    'Speciality'::VARCHAR AS entity_type,
    'name'::VARCHAR AS field_name,
    LOWER(translations.content) AS content,
    NULL::NUMERIC AS latitude,
    NULL::NUMERIC AS longitude,
    NULL::VARCHAR AS h_class,
    NULL::INTEGER AS hospital_id,
    NULL::INTEGER AS department_id,
    specialities.id AS speciality_id,
    NULL::INTEGER AS medication_id,
    NULL::INTEGER AS physician_id,
    NULL::INTEGER AS user_id
  FROM
    specialities
  JOIN
    translations ON specialities.id = translations.entity_id
  WHERE
    translations.entity_type = 'Speciality' AND translations.field_name = 'name'
UNION
  SELECT
    specialities.id AS searchable_id,
    'Speciality'::VARCHAR AS entity_type,
    'name'::VARCHAR AS field_name,
    LOWER(specialities.name) AS content,
    NULL::NUMERIC AS latitude,
    NULL::NUMERIC AS longitude,
    NULL::VARCHAR AS h_class,
    NULL::INTEGER AS hospital_id,
    NULL::INTEGER AS department_id,
    specialities.id AS speciality_id,
    NULL::INTEGER AS medication_id,
    NULL::INTEGER AS physician_id,
    NULL::INTEGER AS user_id
  FROM
    specialities

UNION
  SELECT
    reviews.id AS searchable_id,
    'HospitalReview' AS entity_type,
    'note'::VARCHAR AS field_name,
    LOWER(reviews.note) AS content,
    hospitals.latitude AS latitude,
    hospitals.longitude AS longitude,
    NULL::VARCHAR AS h_class,
    hospitals.id AS hospital_id,
    NULL::INTEGER AS department_id,
    NULL::INTEGER AS speciality_id,
    NULL::INTEGER AS medication_id,
    NULL::INTEGER AS physician_id,
    users.id AS user_id
  FROM
    reviews
  JOIN
    hospitals ON hospitals.id = reviews.reviewable_id
  JOIN
    medical_experiences ON medical_experiences.id = reviews.medical_experience_id
  JOIN
    users ON users.id = medical_experiences.user_id
  WHERE
    reviews.type = 'HospitalReview'

UNION
  SELECT
    reviews.id AS searchable_id,
    'MedicationReview' AS entity_type,
    'note'::VARCHAR AS field_name,
    LOWER(reviews.note) AS content,
    NULL::NUMERIC AS latitude,
    NULL::NUMERIC AS longitude,
    NULL::VARCHAR AS h_class,
    NULL::INTEGER AS hospital_id,
    NULL::INTEGER AS department_id,
    NULL::INTEGER AS speciality_id,
    medications.id AS medication_id,
    NULL::INTEGER AS physician_id,
    users.id AS user_id
  FROM
    reviews
  JOIN
    medications ON medications.id = reviews.reviewable_id
  JOIN
    medical_experiences ON medical_experiences.id = reviews.medical_experience_id
  JOIN
    users ON users.id = medical_experiences.user_id
  WHERE
    reviews.type = 'MedicationReview'

UNION
  SELECT
    reviews.id AS searchable_id,
    'PhysicianReview' AS entity_type,
    'note'::VARCHAR AS field_name,
    LOWER(reviews.note) AS content,
    NULL::NUMERIC AS latitude,
    NULL::NUMERIC AS longitude,
    NULL::VARCHAR AS h_class,
    NULL::INTEGER AS hospital_id,
    NULL::INTEGER AS department_id,
    NULL::INTEGER AS speciality_id,
    NULL::INTEGER AS medication_id,
    physicians.id AS physician_id,
    users.id AS user_id
  FROM
    reviews
  JOIN
    physicians ON physicians.id = reviews.reviewable_id
  JOIN
    medical_experiences ON medical_experiences.id = reviews.medical_experience_id
  JOIN
    users ON users.id = medical_experiences.user_id
  WHERE
    reviews.type = 'PhysicianReview'
;
