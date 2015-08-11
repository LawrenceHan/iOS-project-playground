#!/bin/sh
DIRNAME=`dirname $0`
HOST=api.staging.kangyu.co
TARGET=http://$HOST/v2/search
COUNT=100
CONCURRENCY=3
TODAY=`date +%Y%m%d` 
RESULTS_DIR=~/private_html/$TODAY
mkdir -p $RESULTS_DIR

# record current version
cd sites/webapp/staging/current
/usr/bin/git rev-parse HEAD > $RESULTS_DIR/version.txt

# seems to need to warm up lookup DNS?
/usr/bin/dig +short $HOST > $RESULTS_DIR/dig.txt

# tcv has password-less access to monit
sudo /usr/bin/monit status > $RESULTS_DIR/monit_before.txt

for fixture in `ls $DIRNAME/fixtures/*.json` 
do
  fixture_filename=`basename $fixture`
  echo "Recording results for $fixture"
  /usr/bin/time -f "\t%E real,\t%U user,\t%S sys" /usr/bin/curl -s -d@$fixture "$TARGET" | /usr/bin/json_pp >  $RESULTS_DIR/$fixture_filename.response.json
  if [ "$?" -ne 0 ]; then
    echo "curl query failed! Aborting"
    exit 1
  fi
done

echo "$TODAY, COUNT: $COUNT, CONCURRENCY: $CONCURRENCY"
for fixture in `ls $DIRNAME/fixtures/*.json` 
do
  fixture_filename=`basename $fixture`

  echo "Benchmarking $fixture_filename"
  /usr/bin/time -f "\t%E real,\t%U user,\t%S sys" /usr/bin/ab -n $COUNT -c $CONCURRENCY -T "application/json" -p $fixture -e $RESULTS_DIR/$fixture_filename.csv $TARGET > $RESULTS_DIR/$fixture_filename.txt
  if [ "$?" -ne 0 ]; then
    echo "Benchmarking failed! Aborting"
    exit 1
  fi
done
sudo /usr/bin/monit status > $RESULTS_DIR/monit_after.txt
