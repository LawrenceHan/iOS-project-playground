# Test results

## with concern and audit schema

Not applied and with ```rails_helper.rb:ActiveRecord::Migration.maintain_test_schema!```  disabled

```
RAILS_ENV=test rake db:migrate:status | tail -2
  down    20150113094835  Add audit table triggers
```

run #1

Finished in 37.48 seconds (files took 8.28 seconds to load)
347 examples, 0 failures

run #2

Finished in 39.36 seconds (files took 7.15 seconds to load)
347 examples, 0 failures

## With audit schema


```
$ RAILS_ENV=test rake db:migrate:status | tail -2
   up     20150113094835  Add audit table triggers
```

run #1

Finished in 42.06 seconds (files took 7.68 seconds to load)
347 examples, 0 failures

run #2

Finished in 41.81 seconds (files took 5.81 seconds to load)
347 examples, 0 failures

run #3

Finished in 44.9 seconds (files took 7.97 seconds to load)
347 examples, 0 failures

## without concern and audit schema

run #1

Finished in 34.62 seconds (files took 6.02 seconds to load)
347 examples, 15 failures