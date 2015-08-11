# V2 API Search

## Purpose

v2 search api provides a universal api to search everything.

## Request

To call v2 search api, you must send `POST /v2/search` to server and
send different request body to get different result

```
POST /v2/search

{"query":{"text":"上海"},"sort":{"ranking":true},"page":1,"locale":"zh-CN"}
```

### Parameters

* `query`, Hash, param to filter results
  * `text`, String, search for any matching text, currently it can
search for hospital name, department name, physcian name, health
condition name, symptom name, medication name, medication code,
speciality name, hospital review note, medication review note, physician
review node
  * `type`, String, filter by type, can be one or many of Hospital,
Department, Physician, Condition, HealthCondition, Symptom, Medication,
Speciality, HospitalReview, MedicationReview, PhysicianReview
  * `hospital_id`, Integer, filter by hospital id
  * `department_id`, Integer, fitler by department id
  * `physician_id`, Integer, filter by physician id
  * `medication_id`, Integer, filter by medication id
  * `speciality_id`, Integer, filter by speciality id
  * `user_id`, Integer, filer by user id
  * `area`, Hash, query within area
    * `lat`, Float, current latitude
    * `lng`, Float, current longitude
    * `sw_lat`, Float, south west latitude of area
    * `sw_lng`, Float, south west longitude of area
    * `ne_lat`, Float, north east latitude of area
    * `ne_lng`, Float, north east longitude of area
  * `nearby`, Hash, query nearby things
    * `lat`, Float, current latitude
    * `lng`, Float, current longitude
    * `distance`, Float, search distance, unit is km
* `sort`, Hash, sort results
  * `ranking`, Boolean, sort by top rated
  * `reviews_count`, Boolean, sort by reviews count
  * `h_class`, Boolean, sort by h_class ("三级甲等")
  * `created_at`, Boolean, sort by created_at
  * `distance`, Hash, sort by distance
    * `lat`, Float, current latitude
    * `lng`, Float, current longitude
* `page`, Integer, page number
* `per_page`, Integer, how many results in one page
* `locale`, String, locale, should be one of en-US, zh-CN

## Response

response should be same to v1 search api, but a new field `class_name`
is added, to indicate what type of results.

```
{ "id":1,"class_name":"Hospital",...}
```

## Examples

The followings are some examples that show you how to migrate api v1
search api to v2 search api

Search hospitals by name and sort by distance.

```
GET /v1/search/hospitals/by_name?name=Shanghai&lat=23&lng=100
=>
POST '/v2/search', { query: { text: 'Shanghai' }, sort: { distance: ['23', '100'] } }
```

Search hospitals by name and sort by ranking.

```
GET /v1/search/hospitals/by_name?name=Shanghai&ranking=true
=>
POST '/v2/search', { query: { text: 'Shanghai' }, sort: { ranking: true } }
```

Search hospitals within area.

```
GET
/v1/search/hospitals/within_area?lat=31.2&lng=121.5&sw_lat=28.0&sw_lng=77.2&ne_lat=32.2&ne_lng=122.5
=>
POST '/v2/search', { query: { area: { lat: 31.2, lng: 121.5, sw_lat: 28.0, sw_lng: 77.2, ne_lat: 32.2, ne_lng: 122.5 } } }
```

Search nearby hospitals.

```
GET /v1/search/hospitals/nearby?lat=31.2&lng=121.5&scope=1000.0
=>
POST '/v2/search', { query: { nearby: { lat: 31.2, lng: 121.5, distance: 1000.0 } } }
```

Search physicians by hospital.

```
GET /v1/search/physicians?hospital_id=1
=>
POST '/v2/search', { query: { type: 'Physician', hospital_id: 1 } }
```
