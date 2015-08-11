CREATE MATERIALIZED VIEW aggregated_searches AS
  SELECT
    common_searches.*, reviewable_searches.avg_rating, COALESCE(reviewable_searches.reviews_count, 0) AS reviews_count
  FROM common_searches
  LEFT JOIN
    reviewable_searches ON common_searches.searchable_id = reviewable_searches.reviewable_id AND common_searches.entity_type = reviewable_searches.reviewable_type
;
