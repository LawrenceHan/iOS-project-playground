# Benchmarks

## running benchmarks

curl equivalent:

```
curl -d@benchmark/fixtures/test_physicians_by_name_sort_by_top_rated.json "http://api.staging.kangyu.co/v2/search"
```

ab debug single query:

```
ab -v4 -n 1  -T "application/json" -p benchmark/fixtures/test_physicians_by_name_sort_by_top_rated.json "http://api.staging.kangyu.co/v2/search"
```

Run a 100 queries

```
ab -n 100 -T "application/json" -p benchmark/fixtures/test_physicians_by_name_sort_by_top_rated.json "http://api.staging.kangyu.co/v2/search"
```

## results

### b5ae2dd15f89d8848f341648c2ee3ab79ce04972

| type | v1 | v2 with view | v2 with materialized view |
| ------------- | ------------- | ------------- | ------------- |
| search nearby hospitals, sort by top rated | 11.63 qps, 161 ms | 5.90 qps, 314 ms | 5.46 qps, 315 ms |
| search hospitals by name, sort by distance | 10.40 qps, 166 ms | 5.16 qps, 309 ms | 5.12 qps, 319 ms |
| search physicians by hospital id, sort by top rated | 10.98 qps, 142 ms | 3.70 qps, 383 ms | 3.65 qps, 390 ms |
| search physicians by name, sort by top rated | 17.66 qps, 118 ms | 7.64 qps, 172 ms | 8.98 qps, 173 ms |
| search medications by name, sort by top rated | 5.43 qps, 255 ms | 2.12 qps, 528 ms | 2.12 qps, 521 ms |

```
flyerhzm@huxueyan:~$ ab -n 100 http://api.staging.kangyu.co/v1/search/hospitals/nearby\?lat\=31.245600891113\&lng\=121.3996963501\&scope\=10\&ranking\=true
flyerhzm@huxueyan:~/test_fixtures$ ab -n 100 -p test_nearby_hospitals_sort_by_top_rated.json -T 'application/json' http://api.staging.kangyu.co/v2/search


flyerhzm@huxueyan:~/test_fixtures$ ab -n 100 http://api.staging.kangyu.co/v1/search/hospitals/by_name\?name\=上海\&lat\=31.245600891113\&lng\=121.3996963501
flyerhzm@huxueyan:~/test_fixtures$ ab -n 100 -p test_hospitals_by_name_sort_by_distance.json -T 'application/json' http://api.staging.kangyu.co/v2/search


flyerhzm@huxueyan:~/test_fixtures$ ab -n 100 http://api.staging.kangyu.co/v1/search/physicians\?hospital_id\=57\&ranking\=true
flyerhzm@huxueyan:~/test_fixtures$ ab -n 100 -p test_physicians_by_hospital_id_sort_by_top_rated.json -T 'application/json' http://api.staging.kangyu.co/v2/search


flyerhzm@huxueyan:~/test_fixtures$ ab -n 100 http://api.staging.kangyu.co/v1/search/physicians\?name\=李四波\&ranking\=true
flyerhzm@huxueyan:~/test_fixtures$ ab -n 100 -p test_physicians_by_name_sort_by_top_rated.json -T 'application/json' http://api.staging.kangyu.co/v2/search


flyerhzm@huxueyan:~/test_fixtures$ ab -n 100 http://api.staging.kangyu.co/v1/search/medications\?name\=维生素\&ranking\=true
flyerhzm@huxueyan:~/test_fixtures$ ab -n 100 -p test_medications_by_name_sort_by_top_rated.json -T 'application/json' http://api.staging.kangyu.co/v2/search
```
