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

If you already have most of the round data and just wanted to sync the month of December you could run:

**`bbc-sync --results-directory='./results' --filter='.*December.*' <ggid>`**

**NOTE:** Be sure to substitue `<ggid>` in the command you run with a valid bbc ggid!

**When syncing all the round data it will take a while**, so go get some coffee.

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

**NOTE:** If you see error messages such as:
```
Thu Dec 31 14:37:58 <golfgenius.parser:parser[214]> CRITICAL: Error parsing round Round 36 (Fri, September 11)
Traceback (most recent call last):
  File "/Users/crwelton/virtualenv/bbc-stats/lib/python3.9/site-packages/golfgenius/parser.py", line 208, in iter_rounds
    round_results = self._parse_tournaments()
  File "/Users/crwelton/virtualenv/bbc-stats/lib/python3.9/site-packages/golfgenius/parser.py", line 90, in _parse_tournaments
    assert teams is not None, "Unable to parse teams"
AssertionError: Unable to parse teams
```
This indicates this particular round could not be synced, usually due to incomplete data because golf genius scores were not posted for all 18 holes.
The tool will skip these rounds.

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
bbc-stats --results-directory='./results' --github-site='./website_root' --points-config-file='./website_root/_data/points_config.json'
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
