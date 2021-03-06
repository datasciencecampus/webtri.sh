# ./webtri.sh
[![active](http://www.repostatus.org/badges/latest/active.svg)](http://www.repostatus.org/#active)
[![build](https://travis-ci.org/phil8192/webtri.sh.svg?branch=master)](https://travis-ci.org/phil8192/webtri.sh)
[![codecov](https://codecov.io/gh/phil8192/webtri.sh/branch/master/graph/badge.svg)](https://codecov.io/gh/phil8192/webtri.sh)
![GitHub](https://img.shields.io/github/license/phil8192/webtri.sh.svg)
<p align="center">
  <img src="na/meh.jpg" alt="highways england"/>
</p>

> Unofficial [Highways England](https://www.gov.uk/government/organisations/highways-england)
> [WebTRIS Traffic Flow API](http://webtris.highwaysengland.co.uk/api/swagger/ui/index) shell client.

This script wraps the Highways England webtris API. The webtris API enables one
to extract historical road traffic data for the main roads within the English
trunk road network at 15 minute intervals. The data has been recorded using
[induction loops](https://en.wikipedia.org/wiki/Induction_loop).

Features include:

* [POSIX](http://pubs.opengroup.org/onlinepubs/9699919799/) compliant, portable code between UNIX systems.
* Decoupled [./jq programming language](https://stedolan.github.io/jq/) JSON parsing. Option to produce CSV or JSON output.
* Unit tests with [Bash Automated Testing System](https://github.com/sstephenson/bats) (BATS). See code in [test/](https://github.com/phil8192/webtri.sh/tree/master/test) directory.
* Documented functions, borrowed from Ruby [Tomdoc](http://tomdoc.org/) format. documentation generated using [tomdoc.sh](https://github.com/tests-always-included/tomdoc.sh)
* Fixes a bug detected in official API: Site quality stats will be returned correctly.

## Running

Run

```sh
./webtri.sh
```

For help.

`webtri.sh` takes 2 arguments. `-f <function>` and `-a <args>`. For a summary
use: `./webtri.sh -h`:

```
./webtri.sh -f <function> -a "<args>"
Where <function> is one of:

  get_area, get_quality, get_report, get_sites, get_site_types, get_site_by_type.

  [get_area] Get an area bounding box.
    args
      1. An optional area id.

    The trunk roads are divided up into various pre-defined areas. Given an
    (optional) area id, return the coordinates of a bounding box(es). Return all
    areas if an area id argument has not been supplied.


  [get_quality] Get overall or daily quality.
    args
      1. Comma seperated list of site ids. Or single site id if daily.
      2. ddmmyyyy start period.
      3. ddmmyyyy end period.
      4. overall or daily.

    If overall quality has been specified, gets the quality in terms of a
    percentage score. The percentage represents aggregated site data
    availability for the specified time period. If daily has been specified,
    Gets the day by day percentage quality for each site.

    Note that the orignal API contains a bug in which the overall quality is not
    calculated correctly. If CSV output has been specified (or jq is not
    present) This implementation will automatically correct for this bug.


  [get_report] Get site report.
    args
      1. Comma seperated list of site ids. Or single site id if daily.
      2. ddmmyyyy start period.
      3. ddmmyyyy end period.
      4. overall or daily.

    This is the main part of the API. A site report consists of a number of
    variables for each time period (minimum 15 minute interval) covering vehicle
    lengths, speeds and total counts.


  [get_sites] Get sites.
    args
      1. Comma seperated list of site ids. (optional)

    Get all avaiable site details and status.


  [get_site_types] Get site types.
    Get site types. This is static info.


  [get_site_by_type] Get sites by type.
    args
      1. Site type.
    Filter site information by site type.


  [get_sites_in_box] Get sites within a defined bounding box.
    args
      1. Bounding box South East Longitude
      2. Bounding box South East Latitude
      3. Bounding box North West Longitude
      4. Bounding box North West Latitude


<args> should be inclosed in double quotes.


Examples:

  ./webtri.sh -f get_area         -a 1
  ./webtri.sh -f get_area
  ./webtri.sh -f get_quality      -a "5688 01012018 04012018 daily"
  ./webtri.sh -f get_quality      -a "5688,5699 01012018 04012018 overall"
  ./webtri.sh -f get_report       -a "5688 daily 01012015 01012018"
  ./webtri.sh -f get_report       -a "5688 daily 01012018 01012018"
  ./webtri.sh -f get_sites
  ./webtri.sh -f get_sites        -a 5688
  ./webtri.sh -f get_site_types
  ./webtri.sh -f get_site_by_type -a 1
  ./webtri.sh -f get_sites_in_box -a "-2.007464 53.344107 -2.485731 53.612572"
```

# Examples

## All England MIDAS data between November 2018 and March 2019

There are `11,782` (`./webtri.sh -f get_site_by_type -a 1 |wc -l`)
[MIDAS](https://en.wikipedia.org/wiki/Motorway_Incident_Detection_and_Automatic_Signalling)
sensors.

1. Get a list of all MIDAS sensors

Available types can be obtained with `./webtri.sh -f get_site_types` (1 = MIDAS, 2 = TAME, 3 = TMU).

```bash
./webtri.sh -f get_site_by_type -a 1 > sites.csv
```

2. For each site, download all data in CSV format for the given period:

```bash
mkdir data
for i in $(tail +2 sites.csv |awk -F ',' '{print $1}' |tr -d '"') ;do
  ./webtri.sh -f get_report -a "$i daily 01112018 31032019" > data/"$i".csv
done
```

## Sites within a bounding box

Get all site data between `01-01-2015` and `30-10-2018` for sites inside a bounding
box surrounding the Manchester area.

1. Get sites in bounding box.

```bash
# Manchester
./webtri.sh -f get_sites_in_box -a "-2.007464 53.344107 -2.485731 53.612572" >/tmp/sites.csv

# London
./webtri.sh -f get_sites_in_box -a "0.3335853219 51.234408655 -0.5738564134 51.7504400741" >/tmp/sites.csv
```

2. For each site, get report, store in `site_{id}.csv`

```bash
mkdir -p /tmp/road_data
for i in $(cat /tmp/sites.csv |awk -F ',' '{print $1}' |sed 's/\"//g' |tail +2) ;do
  ./webtri.sh -f get_report -a "$i daily 01012015 30102018" >/tmp/road_data/"$i".csv
done
```

## Documentation

`webtris.sh` can be sourced in/imported or run directly. see [docs](docs.md) for
full function info.

## Dependencies

* [Command-line JSON processor](https://stedolan.github.io/jq/) (optional) If not installed or specified, `webtri.sh` will return raw JSON data.

### Testing and recommended

* [Debian Almquist shell (DASH)](https://www.in-ulm.de/~mascheck/various/ash/)
* [ShellCheck, a static analysis tool for shell scripts](https://github.com/koalaman/shellcheck)
* [Bash Automated Testing System (BATS)](https://github.com/sstephenson/bats)


## License

[MIT](LICENSE)
