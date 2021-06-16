# Lighthouse Page Analysis Tools

This repo contains tooling to analyze the performance of a webpage using [Lighthouse](https://github.com/GoogleChrome/lighthouse).

It provides a Docker container which wraps up Lighthouse, a couple scripts for running the Dockerized Lighthouse against various pages, and tooling to analyze the results in R.

## Setup
```sh
./install.sh
```
should install the Ruby dependency (docopt) and build the Docker container.

## Usage
There are two scripts provided to gather Lighthouse results for URLs:

### Single Lighthouse run:
Use the `lighthouse` script to run a single Lighthouse run against some URL:
```sh
bin/lighthouse [--html] <output_directory> <endpoint_name> <URL>
```

Pass in:
- an output directory to put the result files into
- a name for the endpoint to audit
- an URL

This will emit the full Lighthouse report into the output directory and name it `<endpoint_name>.json`.

Use the `--html` flag to emit the human-readable HTML report instead.

### Lighthouse Performance Analysis
For simplicity, the following examples all assume the `bin` directory is in the user's `PATH`:
```sh
export PATH="$(readlink -e bin):$PATH"
```

Use the `run` script to run a series of Lighthouse runs against a group of pages:
```sh
mkdir -p analysis/results
cd analysis/results
run 'www=https://your-site.com' 'dev=https://your-dev-version:8000'
```

By default it runs three Lighthouse runs against each configuration (three against `your-site.com` and three against `your-dev-version:8000`) and outputs the results to sequentially-numbered JSON files prefixed with the configuration name (`www` and `dev` in this case, so we'd expect files named things like `www_1.json`, `dev_1.json`, etc.). See the help for more on the options it accepts.

Once you've got your runs, boot `RStudio` using the `R-docker` script:
```sh
cd ..
R-docker
```

This will start a Docker container running an instance of RStudio which has access to all the files in the current working directory.

In RStudio, open the `analysis.R` script. Change the `results` line to point at your results directory (if you're following along with our example, it should already be correct). Change the vector of names being passed to `webperf::read_lighthouse_json` to include all the configurations you gathered results for. If needed, change the `3` to be the number of runs you ran (the default for `bin/run` is three, so if you're using the defaults you can leave it alone).

Run all the lines of `analysis.R` through line 15. Then run any of the lines that call `webperf::analyze_change` to analyze the change in the provided metric across your configurations.
