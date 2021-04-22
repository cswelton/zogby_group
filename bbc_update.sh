#!/bin/bash

# This will run the sync and if new round data is synced, rebuild and deploy the website.
# This script needs to be run from the root of the zogby_group repository.
# It is meant to be run in a cron job to automatically update the website following play.

echo "Checking for new round data...";
/Users/crwelton/virtualenv/golfgenius/bin/bbc-sync --results-directory='./results' ekjusj;
retVal=$?;

if [ $retVal -eq 0 ]; then
    echo "round data synced, regenerating website data...";
    /Users/crwelton/virtualenv/golfgenius/bin/bbc-stats --results-directory='./results' --github-site='./website_root' --points-config-file='./website_root/_data/points_config.json'
    retVal=$?;
    if [ $retVal -eq 0 ]; then
        echo "Building website...";
        /Users/crwelton/virtualenv/golfgenius/bin/jekyll build --source='./website_root' --destination='./docs'
        retVal=$?;
        if [ $retVal -eq 0 ]; then
            echo "Deploying website...";
            git add --all && git commit -m 'Updating Website using bbc_update.sh' && git push origin master;
        fi
    fi
else
    echo "All Caught Up";
    exit $retVal;
fi

