"""
main.py

Run Kalpana's nc2shp() function from the CLI. This is used to run a single-use version of the container, where parameters are appended through the command line per Tapis/Design Safe specifications.
"""

import argparse
from kalpana.export import nc2shp
import numpy as np

def main():
    parser = argparse.ArgumentParser(description='Run Kalpana\'s nc2shp() function from the command line.')
    
    parser.add_argument(
        '--ncFile',
        help='Path to netCDF file',
        type=str,
        required=True
    )
    parser.add_argument(
        '--var',
        help='Variable used to generate contours',
        type=str,
        required=True
    )
    parser.add_argument(
        '--levels',
        help='Contour level specification, in the form min max step',
        type=float,
        nargs=3,
        required=True
    )
    parser.add_argument(
        '--conType',
        help='Contour type, polyline or polygon',
        type=str,
        choices=['polyline', 'polygon'],
        required=True
    )
    parser.add_argument(
        '--pathOut',
        help='Path to output, *.shp or *.gpkg',
        type=str,
        required=True
    )
    parser.add_argument(
        '--epsgOut',
        help='EPSG coordinate system for output, 4326 recommended',
        type=int,
        required=True
    )
    parser.add_argument(
        '--vUnitOut',
        help='Units out, m or ft, default is m',
        type=str,
        choices=['m', 'ft'],
        required=False,
        default='m'
    )
    parser.add_argument(
        '--vUnitIn',
        help='Units in, m or ft, default is m',
        type=str,
        choices=['m', 'ft'],
        required=False,
        default='m'
    )
    parser.add_argument(
        '--epsgIn',
        help='EPSG coordinate system for input, default is 4326',
        type=int,
        default=4326,
        required=False
    )
    parser.add_argument(
        '--subDomain',
        help='Full path of the subdomain polygon kml or shapefile, or list of bounding box coordinates separated by spaces W N E S, default is None',
        type=str,
        nargs='+',
        required=False,
        default=None
    )
    parser.add_argument(
        '--epsgSubDom',
        help='EPSG coordinate system for subdomain, default is None',
        type=int,
        required=False,
        default=None
    )
    parser.add_argument(
        '--exportMesh',
        help='Whether to save the ADCIRC mesh as a shapefile, default is False',
        type=bool,
        choices=[True, False],
        required=False,
        default=False
    )
    parser.add_argument(
        '--meshName',
        help='File name of the mesh shapefile, default is None',
        type=str,
        required=False,
        default=None
    )
    parser.add_argument(
        '--dzFile',
        help='Full path to the pickle file with the vertical difference between datums, default is None',
        type=str,
        required=False,
        default=None
    )
    parser.add_argument(
        '--zeroDif',
        help='Threshold for using nearest neighbor interpolation to change datum, otherwise points are unchanged, default is -20',
        type=float,
        required=False,
        default=-20.0
    )
    parser.add_argument(
        '--maxDif',
        help='Threshold to define the percentage of the dz given by the spatial interpolation to be applied, default is -5',
        type=float,
        required=False,
        default=-5.0
    )
    parser.add_argument(
        '--distThreshold',
        help='Distance threshold for limiting the inverse distance-weighted (IDW) interpolation, otherwise points are unchanged, default is 1',
        type=float,
        required=False,
        default=1.0
    )
    parser.add_argument(
        '--k',
        help='Number of points to return in kdtree query, default is 7',
        type=int,
        required=False,
        default=7
    )
    parser.add_argument(
        '--timesteps',
        help='Timesteps to extract if the netCDF file is a time-varying ADCIRC output file, in the form t1 t2 t3 ..., if None, all are exported, default is None',
        type=float,
        nargs='+',
        required=False,
        default=None
    )
    
    # Get arguments
    args = parser.parse_args()
    
    # Process subDomain
    # If a list, convert entries to int
    if args.subDomain != None and len(args.subDomain) > 1:
        args.subDomain = [int(num) for num in args.subDomain]
        
    # Process timesteps
    # Convert to numpy array
    args.timesteps = np.array(args.timesteps)
    
    gdf = nc2shp(
        args.ncFile, # ncFile
        args.var, # var
        args.levels, # levels
        args.conType, # conType
        args.pathOut, # pathOut
        args.epsgOut, # epsgOut
        vUnitOut=args.vUnitOut,
        vUnitIn=args.vUnitIn,
        epsgIn=args.epsgIn,
        subDomain=args.subDomain,
        exportMesh=args.exportMesh,
        meshName=args.meshName,
        dzFile=args.dzFile,
        zeroDif=args.zeroDif,
        maxDif=args.maxDif,
        distThreshold=args.distThreshold,
        k=args.k,
        timesteps=args.timesteps
    )

if __name__ == '__main__':
    main()