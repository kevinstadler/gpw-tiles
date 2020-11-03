#!/bin/sh

INFILE="gpw_v4_population_density_rev10_2015_30_sec.tif"

# truncate population density information at 255/square km
if [ ! -f density.tif ]; then
  gdal_translate -ot Byte -stats -scale -1 500 -co COMPRESS=LZW -co TFW=YES "$INFILE" density.tif
  # original data: mean 55.8 in range up to 55189 (factor 0.001)
  # auto scale leads to mean 6.6 in range up to 255 (factor 0.026)
  # scale to 511 leads to mean 4.23 in range up to 255 (factor 0.0165)
  # scale to 1000 leads to mean 2.569 in range up to 255 (factor 0.01) 
fi

# copy data over to alpha band using ImageMagick
if [ ! -f densityalpha.tif ]; then
  convert density.tif -alpha copy densityalpha.tif
  # recover projection
  mv density.tfw densityalpha.tfw
fi

# generate tiles
gdal2tiles.py --zoom=0-3 --resampling=average -w none --s_srs="+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs" --no-kml densityalpha.tif .
