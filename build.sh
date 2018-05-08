#!/bin/sh

INFILE="gpw_v4_population_density_rev10_2015_30_sec.tif"

# truncate population density information at 255/square km
if [ ! -f density.tif ]; then
  gdal_translate -ot Byte -co COMPRESS=LZW "$INFILE" density.tif
fi

# copy data over to alpha band using ImageMagick
if [ ! -f densityalphaproj.tif ]; then
  convert density.tif -alpha copy densityalpha.tif
  # recover projection
  gdalsrsinfo -o wkt "$INFILE" > proj.wkt
  gdal_translate -a_srs proj.wkt -co COMPRESS=LZW densityalpha.tif densityalphaproj.tif
fi

generate tiles
gdal2tiles.py -w none --resampling=average --s_srs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs" --no-kml densityalphaproj.tif .
