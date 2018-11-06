# OpenSpending Data Importers

This app helps to keep data in OpenSpending as fresh as possible, by pro-actively fetching fiscal data from various data-portals and other official sources. By linking the data in OpenSpending to the exact source, we also gain more credibility for the data stored in the platform.

We use [`datapackage-pipelines`](https://github.com/frictionlessdata/datapackage-pipelines) and specifically [`datapackage-pipelines-fiscal`](https://github.com/openspending/datapackage-pipelines-fiscal) to create and run data pipelines from `fiscal.source-spec.yaml` files. For more information about source-spec files and the appropriate format to use, see the [`datapackage-pipelines-fiscal`](https://github.com/openspending/datapackage-pipelines-fiscal) repository README.

## FAQ

### How do I update my `fiscal.source-spec.yaml` files?

`fiscal.source-spec.yaml` files define data sources, and processing steps to perform on the data, before uploading created datapackages to OpenSpending. The application looks for source-spec files in `/source-specs`. So, where are they? Source-spec files are now kept in a separate repository, [os-source-specs](https://github.com/openspending/os-source-specs). The production deployment of os-data-importers uses a small [repository-agent](https://github.com/openspending/repository-agent) application to keep these files up to date on the server.

To update a datapackage on OpenSpending, either because the source-spec has changed, or because the data itself has been updated, you must make a change to the `fiscal.source-spec.yaml` file and commit it to the master branch of the [os-source-specs](https://github.com/openspending/os-source-specs) repository. If only the data has changed, but not the source-spec, the easiest change to make is to increment the source-spec's `revision` property. Once committed to the repository, the repository-agent will check for changes every 5 minutes, and pull the most recent version. os-data-importers will see that the source-spec has been updated (it is marked as 'dirty'), and will run the pipeline to update the data.

### When will my pipeline run?

A few factors determine when your pipeline will next be run.

**os-data-importers is restarted**: if the os-data-importers application is restarted, usually because it has been redeployed, all pipelines will be re-run.

**fiscal.source-spec.yaml has been updated**: os-data-importers checks for new and updated source-spec content from its known repositories every 5 minutes. If your fiscal.source.spec.yaml file has been updated, the pipeline will be marked as dirty, and rerun.

::TODO:: **on your schedule**: if you fiscal.source-spec.yaml file has a schedule (cron) defined, your pipeline will be rerun according to the schedule. This ensures your data is up to date, even if your fiscal.source-spec.yaml hasn't changed.

## Development notes

### Disable the pipeline scheduler

The env var `$OS_DPP_DISABLE_PIPELINES='True'` will prevent pipeline schedulers from being initialised. This is useful if you want to retain the pipeline server endpoint for your application, but not run the actual pipelines (e.g. for a staging server).

### docker-compose for development

A `docker-compose.dev.yaml` file is provided to start up os-data-importers with a few necessary services (Redis, Postgresql, Elasticsearch, and the repository-agent) without having to run the entire OpenSpending suite. This can be useful during source-spec development to iterate on the specs. Run like this:

```sh
# Start the services os-data-importers uses first:
$ docker-compose -f docker-compose.dev.yaml up -d es redis fakes3 db
# Give it a few seconds for the services to become available, then
# Start up os-data-importers and the repository-agent:
$ docker-compose -f docker-compose.dev.yaml up os-data-importers repository-agent
```

You can access the pipelines dashboard at: `http://localhost:5000`.
