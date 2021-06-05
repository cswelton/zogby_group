### Tutorial: Update Zogby-Group Website

##### **Note**:
This tutorial assumes you have already installed the [bbc-stats](https://github.com/cswelton/bbc-stats)
package along with [*Jekyll*](https://jekyllrb.com/docs/installation/) for your platform. 
If you have not, do that first then come back here.

#### This tutorial will update the zogby group website with all round data available

#### Step 1: Sync the repository
Do this every time before making updates so you pull in the latest copy of the website:
```
git clone https://github.com/cswelton/zogby_group.git
```
Now change into the *zogby_group* directory
```
cd zogby_group
```

#### Step 2: Collect the round data
The first step we need to do is collect the data we need from Golf Genius.

We need to use a GGID code, this can be ANY GGID code from ANY round in the BBC group.

The command below uses the **bbc-sync** tool to collect *all* the score data 
and stores the results in a directory named *results*:

**`bbc-sync --results-directory='./results'  <ggid>`**

**NOTE:** Be sure to substitue `<ggid>` in the command you run with a valid bbc ggid!

By default, this will sync over all rounds that have not been collected yet.
If you want to resync all round data (even those previously collected) add the `--sync-all` option.

If you want to filter out round names you can pass in a regular expression with the `--filter` option, 
for example if you just wanted to sync the month of December you could add: `--filter='.*December.*'`.

You should see output similar to this:
```
Fri Dec 18 19:13:58 <root:sync_golfgenius[66]> INFO: Refreshing BBC Results from GGID ***** to ./results
Fri Dec 18 19:14:01 <golfgenius.parser:parser[170]> INFO: Logging into https://www.golfgenius.com/golfgenius
Fri Dec 18 19:14:34 <golfgenius.parser:parser[191]> INFO: Discovered 56 rounds matching pattern .*. (56 total)
Thu Dec 31 14:32:46 <golfgenius.parser:parser[210]> INFO: Stored Round 60 (Thu, December 31) (16 players)
Thu Dec 31 14:33:04 <golfgenius.parser:parser[210]> INFO: Stored Round 59 (Wed, December 23) (16 players)
...
```
Once all rounds have synced a final message is printed:
```
Fri Dec 18 19:16:45 <root:sync_golfgenius[79]> INFO: Finished refreshing GGID *****. Results have been stored in ./results
```

We now have our score data in the *results/* folder:

```
$ ls results
Round 47 (Fri, November  6).json	Round 50 (Fri, November 20).json	Round 53 (Fri, November 27).json	Round 56 (Fri, December 11).json
Round 48 (Tue, November 10).json	Round 51 (Tue, November 24).json	Round 54 (Sun, November 29).json	Round 57 (Sun, December 13).json
Round 49 (Sat, November 14).json	Round 52 (Wed, November 25).json	Round 55 (Fri, December  4).json
$ 
```

Next we will use the `bbc-stats` tool to parse these results into the data files for the website.

#### Step 3: Parse rounds into data files for website
The website is driven by data stored in various files located in this repository under *website_root/*.
This step will build those data files using the *results/* files we collected in step #1.

```
bbc-stats --results-directory='./results' --github-site='./website_root' --points-config-file='./website_root/_data/points_config.json' --blacklist-rounds-file='./website_root/_data/BLACKLISTED_ROUNDS'
```

This will printout 2 tables, a power-rankings summary and a points summary.
It will also update the data files under `website_root/` folder.

Now we can test and verify the website before we push it live.

#### Step 4: Test and Verify website
We're going to run the website locally so we can verify it looks right before we
push it live.

First, start the website locally:
```
jekyll serve --source='./website_root' --destination='./docs' --baseurl=''
```
You should see output similar to this:
```
Configuration file: /Users/crwelton/GIT_DIR/zogby_group_prod/website_root/_config.yml
            Source: /Users/crwelton/GIT_DIR/zogby_group_prod/website_root
       Destination: /Users/crwelton/GIT_DIR/zogby_group_prod/docs
 Incremental build: disabled. Enable with --incremental
      Generating... 
                    done in 0.841 seconds.
 Auto-regeneration: enabled for './website_root'
    Server address: http://127.0.0.1:4000/
  Server running... press ctrl-c to stop.
```
Now, open your browser and navigate to http://127.0.0.1:4000 to verify the
website is operational and contains the updated data.

When your ready to proceed, press `ctrl-c` to stop the local server.

#### Step 5: Build and Push the website live
Once we are satisfied with the website its time to build and push it live.

First, rebuild the website into the *docs/* folder:
```
jekyll build --source='./website_root' --destination='./docs'
```
Output:
```
Configuration file: /Users/crwelton/GIT_DIR/zogby_group_prod/website_root/_config.yml
            Source: /Users/crwelton/GIT_DIR/zogby_group_prod/website_root
       Destination: /Users/crwelton/GIT_DIR/zogby_group_prod/docs
 Incremental build: disabled. Enable with --incremental
      Generating... 
                    done in 5.491 seconds.
 Auto-regeneration: disabled. Use --watch to enable.
```

Then push live:

```
git add --all
git commit -m 'Updating Website'
git push
```
Once pushed, github will deploy the website usually in under 1 min.
You can view the status of the deployments here:
https://github.com/cswelton/zogby_group/deployments/activity_log?environment=github-pages
Look for the most recent deployment, it may take a minute to show up.

#### If there was a problem
If the website was already deployed (using the git push command above), then you first need to
revert that commit.

First run the `git log` command to get the list of commits. The most recent commit will be at the
top.  

Find the commit id (long string) and copy that to your clipboard. Exit out of the log using `q`.

Then run the command `git revert <id>` but substitute `<id>` with the commit id you copied.

After the revert is finished run
```
git push
```
and the website will be reverted to the state before that commit was made.
