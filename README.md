## Divorce, parental conflicts and child skills: A story of selection.

![MATLAB](https://img.shields.io/badge/MATLAB-%23e76a24.svg?style=for-the-badge&logo=matlab&logoColor=white)

This repository contains the replication code for:

Moroni, G. & Vickery, A. (2025). _Divorce, parental conflicts and child skills: A story of selection_, authored by [Gloria Moroni](https://gloriamoroni.wixsite.com/gloriamoroni/research) &amp; [Alexander Vickery](https://www.alexander-vickery.com/), published in the [Labour Economics](https://doi.org/10.1016/j.labeco.2025.102830) in December 2025.

This paper uses data from the UK Millennium Cohort Study (MCS) to study how parental divorce in early childhood affects a child's skill development.

## Links to the Paper

The paper and supplementary material are available at [https://doi.org/10.1016/j.labeco.2025.102830](https://doi.org/10.1016/j.labeco.2025.102830).

---

## Software Requirements

- **MATLAB** (tested on R2022b and later)

---

## Data

The analysis uses **UK Millennium Cohort Study (MCS)** data from waves 1–5 (children born 2000–01, followed at ages 3, 5, 7, and 11).

Access to the MCS is **restricted** and must be obtained separately:

1. Register at the [UK Data Service](https://ukdataservice.ac.uk/),
2. Apply for access to the MCS datasets,
3. See `data/DATA_README.md` for detailed instructions on which variables are used and how to prepare the input file.

Once obtained, place the prepared dataset at:

```
data/sample_data.csv
```

---

## Replication Instructions

1. Clone or download this repository,
2. Obtain the MCS data (see **Data** section above) and place `sample_data.csv` in `data/`,
3. Open MATLAB,
4. Navigate to the repository root directory (`cd /path/to/replication_package`),
5. Run the master script:

```matlab
run_all
```

All outputs will be saved under `output/`.

> **Note:** Step 2 (EM estimation over 250 bootstrap samples) is computationally intensive and can take several hours to complete. Steps 3–5 (creating output tables and figures) can be run independently once estimation is complete by running the individual scripts in `analysis/`.

---

## Output Map

| Paper Output    | Script                                          | Output File                                                          |
| --------------- | ----------------------------------------------- | -------------------------------------------------------------------- |
| Figure 1        | `analysis/docfact.m`                            | `output/figures/cog_cfact_age*.pdf`, `emo_cfact_age*.pdf`            |
| Table 5         | `analysis/make_tabs.m`                          | `output/tables/prod_f.tex`                                           |
| Table 6         | `analysis/make_tabs.m`                          | `output/tables/div_con.tex`                                          |
| Figures A.3–A.4 | `analysis/domodel_summary.m` -> `model_fit.m`   | `output/figures/model_fit_divorce*.pdf`, `model_fit_no_divorce*.pdf` |
| Figures A.5–A.6 | `analysis/docfact.m`                            | `output/figures/cog_cfact_1_age*.pdf`, `emo_cfact_1_*.pdf`           |
| Figures A.7–A.8 | `analysis/docfact.m`                            | `output/figures/cog_cfact_1_male_age*.pdf`, `*_female_*.pdf`         |
| Table A.11      | `analysis/make_tabs.m`                          | `output/tables/tfp_cog.tex`                                          |
| Table A.12      | `analysis/make_tabs.m`                          | `output/tables/tfp_emo.tex`                                          |
| Table A.13      | `analysis/make_tabs.m`                          | `output/tables/unob_het.tex`                                         |
| Table A.14      | `analysis/domodel_summary.m` → `divorce_gaps.m` | `output/tables/divorce_gaps.tex`                                     |

---

## Directory Structure

```
replication_package/
├── run_all.m          Master script — runs all replication steps in order.
├── README.md          This readme file.
├── .gitignore
│
├── data/              Data preparation scripts
│   ├── DATA_README.md Instructions for obtaining the MCS data.
│   ├── readdata.m     Reads the raw .csv file, constructs bootstrap samples.
│   ├── modeldata.m    Constructs the factor model and production function data.
│   └── getdata.m      Helper function to load the bootstrap-resampled data.
│
├── estimation/        EM estimation of the structural model
│   ├── dotranslog.m   Main estimation loop (calls translog.m for each bootstrap replication).
│   ├── translog.m     One EM iteration for the translog production function.
│   ├── translog_like.m     Log-likelihood and posterior type probabilities.
│   ├── translog2LVLmle.m   MLE for translog input elasticities.
│   ├── translog_lnpred.m   Deterministic production function component.
│   ├── translog_ydet.m     TFP covariate component.
│   └── convg_checktranslog.m  Convergence diagnostics for the EM algorithm.
│
├── analysis/          Results scripts
│   ├── docfact.m           Counterfactual simulations -> figures.
│   ├── domodel_summary.m   Model fit + divorce gaps table (calls below).
│   ├── divorce_gaps.m      Computes data vs. model predicted divorce skill gaps.
│   ├── model_divorce_gaps_tab.m  Writes divorce gaps table.
│   ├── model_fit.m         Simulates skill distributions to show model fit.
│   ├── model_fit_fig.m     Plots the model fit figures.
│   └── make_tabs.m         Creates all of the parameter estimate tables.
│
├── functions/         Shared helper functions
│   ├── em_alg2.m      Generic EM algorithm.
│   ├── sim_model.m    Simulates child skill trajectories.
│   └── AddCommaArr.m  Formats numbers with significance stars for LaTeX tables.
│
└── output/            Generated files
    ├── estimates/     PF_0.mat through PF_250.mat -> parameter estimates.
    ├── figures/       PDFs of each figure file.
    └── tables/        .tex files for each table.
```

---

## Notes

- **Bootstrap:** Standard errors are based on 250 cluster-bootstrap samples (clustered on child sex x divorce status).
- **Seed:** `rng(10)` is set in `readdata.m` before drawing bootstrap indices, to ensure reproducibility.
- **Estimation time:** Each bootstrap sample requires approximately 1–5 minutes depending on your machine.
