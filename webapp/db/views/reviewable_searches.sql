CREATE OR REPLACE VIEW reviewable_searches AS
  SELECT
    hospitals.id AS reviewable_id,
    'Hospital' AS reviewable_type,
    COUNT(reviews.id) AS reviews_count,
    AVG(reviews.avg_rating) AS avg_rating
  FROM
    hospitals
  JOIN
    reviews ON reviews.reviewable_id = hospitals.id
  WHERE
    reviews.type = 'HospitalReview' AND status = 'published'
  GROUP BY
    hospitals.id
UNION
  SELECT
    medications.id AS reviewable_id,
    'Medication' AS reviewable_type,
    COUNT(reviews.id) AS reviews_count,
    AVG(reviews.avg_rating) AS avg_rating
  FROM
    medications
  JOIN
    reviews ON reviews.reviewable_id = medications.id
  WHERE
    reviews.type = 'MedicationReview' AND reviews.status = 'published'
  GROUP BY
    medications.id
UNION
  SELECT
    physicians.id AS reviewable_id,
    'Physician' AS reviewable_type,
    COUNT(reviews.id) AS reviews_count,
    AVG(reviews.avg_rating) AS avg_rating
  FROM
    physicians
  JOIN
    reviews ON reviews.reviewable_id = physicians.id
  WHERE
    reviews.type = 'PhysicianReview' AND reviews.status = 'published'
  GROUP BY
    physicians.id
