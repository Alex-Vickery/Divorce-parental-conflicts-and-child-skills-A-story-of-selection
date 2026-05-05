# Data Instructions

## UK Millennium Cohort Study (MCS)

The analysis uses restricted-access data from the UK Millennium Cohort Study, available through the **UK Data Service**.

### How to Obtain the Data

1. Create an account at [UK Data Service](https://ukdataservice.ac.uk/)
2. Accept the End User Licence for each dataset
3. Download the following MCS studies:
   - **MCS Wave 1** (age 3): SN 4683
   - **MCS Wave 2** (age 5): SN 5350
   - **MCS Wave 3** (age 7): SN 5795
   - **MCS Wave 4** (age 11): SN 6411


### Preparing the Input File

Merge the required variables across waves into a single CSV file with one row per child. The file must be named:

```
sample_data.csv
```

and placed in the `data/` directory of this replication package.

The column names must exactly match those listed in the table above (as read by `data/readdata.m`).
