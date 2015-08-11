CREATE OR REPLACE VIEW common_searches AS
  SELECT
    departments.id AS searchable_id,
    'Department'::VARCHAR AS entity_type,
    LOWER(CONCAT(chinese_departments.name, ' ', english_departments.name)) AS content,
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
  LEFT JOIN
    department_translations chinese_departments ON departments.id = chinese_departments.department_id AND chinese_departments.locale = 'zh-CN'
  LEFT JOIN
    department_translations english_departments ON departments.id = english_departments.department_id AND english_departments.locale IN ('en-US', 'en')
  JOIN
    departments_hospitals ON departments.id = departments_hospitals.department_id
  JOIN
    hospitals ON departments_hospitals.hospital_id = hospitals.id
UNION
  SELECT
    physicians.id AS searchable_id,
    'Physician'::VARCHAR AS entity_type,
    LOWER(CONCAT(chinese_physicians.name, ' ', english_physicians.name, ' ',  chinese_departments.name, ' ', english_departments.name, ' ', chinese_hospitals.name, ' ', english_hospitals.name)) AS content,
    hospitals.latitude AS latitude,
    hospitals.longitude AS longitude,
    hospitals.h_class AS h_class,
    hospitals.id AS hospital_id,
    departments.id AS department_id,
    specialities.id AS speciality_id,
    NULL::INTEGER AS medication_id,
    physicians.id AS physician_id,
    NULL::INTEGER AS user_id
  FROM
    physicians
  LEFT JOIN
    physician_translations chinese_physicians ON physicians.id = chinese_physicians.physician_id AND chinese_physicians.locale = 'zh-CN'
  LEFT JOIN
    physician_translations english_physicians ON physicians.id = english_physicians.physician_id AND english_physicians.locale IN ('en-US', 'en')
  JOIN
    physicians_specialities ON physicians.id = physicians_specialities.physician_id
  JOIN
    specialities ON specialities.id = physicians_specialities.speciality_id
  JOIN
    departments ON physicians.department_id = departments.id
  LEFT JOIN
    department_translations chinese_departments ON departments.id = chinese_departments.department_id AND chinese_departments.locale = 'zh-CN'
  LEFT JOIN
    department_translations english_departments ON departments.id = english_departments.department_id AND english_departments.locale IN ('en-US', 'en')
  JOIN
    hospitals ON physicians.hospital_id = hospitals.id
  LEFT JOIN
    hospital_translations chinese_hospitals ON hospitals.id = chinese_hospitals.hospital_id AND chinese_hospitals.locale = 'zh-CN'
  LEFT JOIN
    hospital_translations english_hospitals ON hospitals.id = english_hospitals.hospital_id AND english_hospitals.locale IN ('en-US', 'en')
UNION
  SELECT
    health_conditions.id AS searchable_id,
    health_conditions.type AS entity_type,
    LOWER(CONCAT(chinese_health_conditions.name, ' ', english_health_conditions.name)) AS content,
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
  LEFT JOIN
    health_condition_translations chinese_health_conditions ON health_conditions.id = chinese_health_conditions.health_condition_id AND chinese_health_conditions.locale = 'zh-CN'
  LEFT JOIN
    health_condition_translations english_health_conditions ON health_conditions.id = english_health_conditions.health_condition_id AND english_health_conditions.locale IN ('en-US', 'en')
UNION
  SELECT
    hospitals.id AS searchable_id,
    'Hospital'::VARCHAR AS entity_type,
    LOWER(CONCAT(chinese_hospitals.name, ' ', english_hospitals.name)) AS content,
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
  LEFT JOIN
    hospital_translations chinese_hospitals ON hospitals.id = chinese_hospitals.hospital_id AND chinese_hospitals.locale = 'zh-CN'
  LEFT JOIN
    hospital_translations english_hospitals ON hospitals.id = english_hospitals.hospital_id AND english_hospitals.locale IN ('en-US', 'en')
UNION
  SELECT
    medications.id AS searchable_id,
    'Medication'::VARCHAR AS entity_type,
    LOWER(CONCAT(chinese_medications.name, ' ', english_medications.name, ' ', medications.code)) AS content,
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
  LEFT JOIN
    medication_translations chinese_medications ON medications.id = chinese_medications.medication_id AND chinese_medications.locale = 'zh-CN'
  LEFT JOIN
    medication_translations english_medications ON medications.id = english_medications.medication_id AND english_medications.locale IN ('en-US', 'en')
UNION
  SELECT
    specialities.id AS searchable_id,
    'Speciality'::VARCHAR AS entity_type,
    LOWER(CONCAT(chinese_specialities.name, ' ', english_specialities.name)) AS content,
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
  LEFT JOIN
    speciality_translations chinese_specialities ON specialities.id = chinese_specialities.speciality_id AND chinese_specialities.locale = 'zh-CN'
  LEFT JOIN
    speciality_translations english_specialities ON specialities.id = english_specialities.speciality_id AND english_specialities.locale IN ('en-US', 'en')
UNION
  SELECT
    reviews.id AS searchable_id,
    'HospitalReview' AS entity_type,
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
