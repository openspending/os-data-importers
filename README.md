# OS-Data-Importers

## Goal

The aim of this project is to keep the data in OpenSpending as fresh as possible, by proactively fetching up-to-dat fiscal data from various data-portals and other official sources. By linking the data in OpenSpending to the exact source, we also gain more credibility to the data stored in the platform.

## Basics

This repo is organised by Geography - each country (and country-like entity as the EU) has its own subdirectory in the file system.
Under this directory, more subdirectories may be added to represent administrative regions, municipalities etc.

Each of these folders contains instructions for fetching fiscal data. These instructions include:
 - **Source**
   The location on the Internet from which this data should be fetched
 - **Schedule**
   When should the data be fetched? For example: on the 15th of every calendar month or every 24 hours
 - **Method**
   Some data can be downloaded directly as a file from a static URL, while others might need more complicated methods (or even scraping a website).
