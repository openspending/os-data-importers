# OS-Data-Importers

## Goal

The aim of this project is to keep the data in OpenSpending as fresh as possible, by proactively fetching up-to-date 
fiscal data from various data-portals and other official sources. By linking the data in OpenSpending to the exact 
source, we also gain more credibility to the data stored in the platform.

## Basics

This repo is organised by Geography - each country (and country-like entity as the EU) has its own subdirectory in the 
file system.
Under this directory, more subdirectories may be added to represent administrative regions, municipalities etc.

Each of these folders contains instructions for fetching fiscal data. These instructions include:
 - **Source**
   The location on the Internet from which this data should be fetched
 - **Schedule**
   When should the data be fetched? For example: on the 15th of every calendar month or every 24 hours
 - **Method**
   Some data can be downloaded directly as a file from a static URL, while others might need more complicated methods 
   (or even scraping a website).

The framework will execute each of these importers on the specified schedule, and make sure that the fetched data is 
uploaded to OpenSpending DB.

## More Details

This repo consists of *Fetchers*, *Processors* and *Running Instructions*.

 - Fetchers: Python scripts which get tabular data located somewhere on the web and output a Fiscal Data Package (FDP).
 - Processors: Python scripts which get an FDP as input, modify it and output a new FDP.
 - Running Instructions: A set of rules that define a pipeline of a single fetcher and subsequent processors and a schedule.

The final FDP output from a pipeline must be complete - all metadata and mapping must be present and valid.
 
## Running Instructions

Running instructions are stored in this repo in files named `data-importer.yaml`. 

Each one of these files is a YAML file which contains instructions for fetching one or more FDPs. For example, such a 
file might look like this:

```
albonian-spending:
    schedule:
        cron: '3 0 * * *'
    pipeline:
        - 
            run: fetch-albonian-fiscal-data
            parameters:
                kind: 'expenditures'
        -   
            run: translate-codelists
        -
            run: normalize-dates
albonian-budget:
    schedule:
        cron: '0 0 7 1 *'
    pipeline:
        - 
            run: fetch-albonian-fiscal-data
            parameters:
                kind: 'budget'
        -   
            run: translate-codelists
```

**What do we have here?**

Two running instructions for two separate FDPs - one fetching the Albonian spending data and another fetching its budget 
 data. You can see that the pipelines are very similar, and are based on the same building blocks: 
 `fetch-albonian-fiscal-data`, `translate-codelists` and `normalize-dates`. The differences between the two are 
 - their schedules: spending data is fetched on a daily basis, whilst budgets are fetched on January 7th every year 
        (Albonian government officials adhere to very precise publishing dates)
 - the running parameters for the fetcher are different - so that code is reused and controlled via running parameters
 - the pipeline for spending data has an extra step (`normalize-dates`)
 
**Spec:**

This YAML file is basically a mapping between *Pipeline IDs* to their specs. Task IDs are the way we reference the
pipeline in various places so choose wisely.

A pipeline spec has two keys:
 - `schedule`: can have one sub-key, which can be either `cron` or `every`. The value for the former is a standard
    `crontab` schedule row, while the latter is a string of the form `XX seconds` / `YY minutes` etc. (you can also use
     `hours` & `days`).
 - `pipeline`: a list of steps, each is an object with the following properties:
    - `run`: the name of the executor - a Python script which will perform the step's actions.
        This script is searched in the current directory (read: where the running instructions file is located), or 
        in the common lib of executors (in that order).
        Relative paths can be specified with the 'dot-notation': `a.b` is referring to script `b` in directory `a`; 
        `...c.d.e` will look for `../../c/d/e.py`. 
    - `parameters`: running parameters which the executor will receive when invoked.
     
The first executor in all pipelines must be a fetcher and the rest of the steps must be processors.
 
## Executors

Executors are Python scripts with a simple API, based on their standard input & standard output streams (as well as
  command line parameters).

All executors output an FDP to the standard output. This is done in the following way:
 - The first line printed to `stdout` must be the contents of the `datapackage.json` - that is, a JSON object without
  any newlines.
 - After that first line, tabular data files can be appended (we don't support any other kind of files ATM).
   Each tabular data file must be printed out in the following way:
     - First line must always be an empty line (that is, just a single newline character).
     - Subsequent lines contain the contents of the data rows of the file (i.e. no header row or other chaff)
     - Each row in the file must be printed as a single-line JSON encoded object, which maps the header names to values
     
Processors will receive an FDP in the exact same format in their stdin. Fetchers will receive nothing in their stdin.

Parameters are passed as a JSON encoded string in the first command line argument of the executor.

Files should appear in the same order as the resources defined in the FDP. Only data for local files is expected - 
 remote resources can just be ignored.
      
### Why JSON and not CSV?

Well, for a multitude of reasons:
 - JSON encoding is not dependent on locale settings of the executing machine
 - JSON has better type indication: strings vs. numbers vs. booleans vs. missing values (with time and date values as 
  the only exception)
 - JSON is easier to work with in Python
 
*What about time and dates, then?* 
Just use their string representation and make sure that the JSON Table Schema contains the correct format definition
 for that field.
 
The framework will take these JSONs and convert them to proper CSV files before uploading - with a correct dialect, 
encoding and locale info.

## Developing Executors

To avoid boilerplate, the `ingest` and `spew` utility functions for executors can come in handy:

```python

from executor_util import ingest, spew

if __name__=="__main__":
  params, fdp, resource_iterator = ingest()
  
  # do something with fdp
  # ...
  
  def process_resource(resource):
    for row in resource:
      # do something with row
      # ...
      yield row
      
  spew(fdp, (process_resource(r) for r in resource_iterator))
  
```
  
