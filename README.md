# 🐿️ Central Park Squirrel Census Dashboard

An interactive data visualization dashboard for exploring behavioral
patterns of squirrels in New York City's Central Park, built with R
Shiny using data from the **2018 Central Park Squirrel Census**.

Users can filter sightings by time frame and age to analyze fur color
distributions, activity shifts, and individual sighting records —
supporting both casual park visitors and wildlife researchers.

🔗 **Live app:**
<https://019ce8fb-5535-3112-1c63-4c9bbb4b484c.share.connect.posit.cloud/>

------------------------------------------------------------------------

## Features

-   Filter squirrel sightings by **age** and **time of day (shift)**
-   Visualize patterns with **fur color** and **shift count** charts
-   Browse exact records in an interactive **data table**

------------------------------------------------------------------------

## Running Locally

### Prerequisites

-   [R](https://www.r-project.org/) ≥ 4.1.0
-   [RStudio](https://posit.co/download/rstudio-desktop/) (recommended)

### 1. Clone the repository

``` bash
git clone https://github.com/Natalie1339/532_individual.git
cd 532_individual
```

### 2. Install required packages

Open R or RStudio and run:

``` r
source("install.R")
```

### 3. Prepare the data

``` r
source("data_processing.R")
```

### 4. Launch the app

``` r
shiny::runApp("app.R")
```

Or open `app.R` in RStudio and click **Run App** in the top-right
corner.

The app will open in your browser at `http://127.0.0.1:<port>`.

------------------------------------------------------------------------

## Project Structure

| File / Folder       | Description                               |
|---------------------|-------------------------------------------|
| `app.R`             | Main Shiny application (UI + server)      |
| `data_processing.R` | Data cleaning and preparation scripts     |
| `install.R`         | Installs all required R packages          |
| `data/`             | Raw and processed census data             |
| `www/`              | Static assets (CSS, images, JS)           |
| `manifest.json`     | App manifest for Posit Connect deployment |

------------------------------------------------------------------------

## Data Source

[2018 Central Park Squirrel
Census](https://data.cityofnewyork.us/Environment/2018-Central-Park-Squirrel-Census-Squirrel-Data/vfnx-vebw)
— NYC Open Data
