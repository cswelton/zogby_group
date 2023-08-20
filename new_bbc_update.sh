#!/bin/bash


echo "Checking for new round data...";
/home/craig/venv/bin/bbc-sync --results-directory='./results' uspfuw;
retVal=$?;

if [ $retVal -eq 0 ]; then
    echo "round data synced, regenerating website data...";
    /home/craig/venv/bin/bbc-stats --results-directory='./results' --github-site='./website_root' --points-config-file='./website_root/_data/points_config.json' --blacklist-rounds-file='./website_root/_data/BLACKLISTED_ROUNDS'
    retVal=$?;
    if [ $retVal -eq 0 ]; then
        echo "Building website...";
        docker run --rm --volume="$PWD:/srv/jekyll:Z" -it jekyll/builder jekyll build --source website_root --destination docs
        retVal=$?;
        if [ $retVal -eq 0 ]; then
            echo "Deploying website...";
            ssh-agent bash -c 'ssh-add /home/craig/.ssh/id_rsa; git add --all && git commit -m "Updating Website using bbc_update.sh" && git push origin master';
        fi
    fi
else
    echo "All Caught Up";
    exit $retVal;
fi
