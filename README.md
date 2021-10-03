# Ensembl API Coordinate Conversion

This repository is part of exercise on Ensemble Perl API usage. Here, code to convert human genome assembly latest release GRCh38 from chromosome coordinate system to same system but different version is given.

The exercise target is to convert chromosome 10's seq no 25 to 30 coordinates (in GRCh38 version) to GRCh37 coordinate version.

## Tested Environment
- Ubuntu 18.04 LTS
- Bash shell
- Perl v5.26.1
- Ensembl API version 104

## Installation
### Ensembl Perl API install
Follow this youtube [video](https://youtu.be/nxTFcKi1nDw) instruction.
Written instruction can be found in this [link](https://asia.ensembl.org/info/docs/api/api_installation.html) from ensembl official documentation site.

### Other Installation
Ensembl API use Perl API to extract data from mysql database. For that you may need to install some extra library
```
sudo apt-get install libdbi-perl libdbd-mysql libdbd-mysql-perl
```

## Usage
Provided script can report mapping of GRCh38 sequence coordinate to any valid coordinate system,version. If no conversion is available for the target system:version, it will print nothing.

To run the script as executable, first set the script file executable permission
```
chmod +x coordinate_conv.pl
```
Then run like following, 
```
./coordinate_conv.pl <chromosome number> <start coordinate in GRCh38> <end coordinate in GRChh38> <new coordinate system name> <new coordinate version>
```

If executable permission cannot be given run like following,
```
perl coordinate_conv.pl <chromosome number> <start coordinate in GRCh38> <end coordinate in GRChh38> <new coordinate system name> <new coordinate version>
```
### Example Usage
If we want to get mapping report of chromosome 10's seq 25 to 30 (inclusive, in GRCh38 version) to chromosome coordinate system version GRCh37, the inputs will be,

- chromosome number = 10
- start coordinate in GRCh38 = 25
- end coordinate in GRCh38 = 30
- new coordinate system name = chromosome
- new coordinate version = GRCh37

The cmd will be
```
./coordinate_conv.pl 10 25 30 chromosome GRCh37
```
or if not executable
```
perl coordinate_conv.pl 10 25 30 chromosome GRCh37
```
