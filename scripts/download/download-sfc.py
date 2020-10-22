#!/usr/bin/env python
import cdsapi
import os

datadir = '/n/holyscratch01/kuang_lab/nwong/TropicalRCE/data/reanalysis/'

c = cdsapi.Client()
c.retrieve(
    'reanalysis-era5-single-levels-monthly-means',
    {
        'format': 'netcdf',
        'product_type': 'monthly_averaged_reanalysis',
        'variable': [
            'surface_net_solar_radiation',
            'surface_net_thermal_radiation',
            'surface_sensible_heat_flux',
            'surface_latent_heat_flux',
            'top_net_solar_radiation',
            'top_net_thermal_radiation',
            'high_cloud_cover',
            'medium_cloud_cover',
            'low_cloud_cover',
            'total_cloud_cover',
            'sea_surface_temperature',
            '2m_temperature',
            'total_column_water',
            'total_column_water_vapour',
            'land_sea_mask',
        ],
        'year': [
            1979, 1980, 1981, 1982, 1983, 1984, 1985, 1986, 1987, 1988,
            1989, 1990, 1991, 1992, 1993, 1994, 1995, 1996, 1997, 1998,
            1999, 2000, 2001, 2002, 2003, 2004, 2005, 2006, 2007, 2008,
            2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019,
        ],
        'month': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
        'area': [30, 0, -30, 360],
        'time': '00:00',
    },
    datadir + 'era5-TRPx0.25-sfc.nc')
