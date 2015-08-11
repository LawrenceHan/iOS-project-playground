class CreateDistanceInKmFunction < ActiveRecord::Migration
  def change
    execute <<-SQL
      CREATE OR REPLACE FUNCTION public.distance_in_km(alat double precision, alng double precision, blat double precision, blng double precision)
      RETURNS double precision AS
      $BODY$
      SELECT asin(
        sqrt(
          sin(radians($3-$1)/2)^2 +
        sin(radians($4-$2)/2)^2 *
          cos(radians($1)) *
          cos(radians($3))
        )
      ) * 6371 * 2 AS distance;
      $BODY$
      LANGUAGE sql IMMUTABLE
      COST 100;
    SQL
  end
end
