# Headless Lighthouse Runner

A Docker container for Lighthouse (i.e., https://github.com/GoogleChrome/lighthouse).

This is a handy wrapper layer that allow for running

### Usage
```
Usage:                                                    
 run.rb [--html] <output_directory> <endpoint_name> <URL>
```

Pass in:
- an output directory to put things into
- a name for the endpoint to audit
- an URL

This will emit the full Lighthouse report into the output directory at
`<endpoint>.json`.

Use the `--html` flag to emit the human-readable HTML report instead.
