# OS-Data-Importers

## Goal

The aim of this project is to keep the data in OpenSpending as fresh as possible, by proactively fetching up-to-date 
fiscal data from various data-portals and other official sources. By linking the data in OpenSpending to the exact 
source, we also gain more credibility to the data stored in the platform.

## Means

We use the `datapackage-pipelines` framework to run the processing pipelines.

## Current Status

#### Mexico 2008-2016 Budget (Cuenta Pública): [![Pipeline](http://staging.openspending.org/pipelines)

## Development notes

The env var `$OS_DPP_DISABLE_PIPELINES='True'` will prevent pipeline schedulers from being initialised. This is useful if you want to retain the pipeline server endpoint for your application, but not run the actual pipelines (e.g. for a staging server). 
