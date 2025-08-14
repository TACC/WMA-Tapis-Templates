"""
main.py

Run Kalpana's nc2shp() function from the CLI. This is used to run a single-use version of the container, where parameters are appended through the command line per Tapis/Design Safe specifications.
"""

from kalpana.export import nc2shp

def main(args, kwargs**):
    #### @TODO fill in variables
    gdf = nc2shp(
        r"/mnt/host/maxele.63.nc", # ncFile
        "zeta_max", # var
        [0, 5.5, 0.5], # levels
        "polygon", # conType
        r"/mnt/host/contours.gpkg", # pathOut
        4326, # epsgOut
        vUnitOut="m",
        vUnitIn="m",
        epsgIn=4326,
        subDomain=None,
        exportMesh=False,
        meshName=None,
        dzFile=None,
        zeroDif=-20,
        maxDif=-5,
        distThreshold=0.5,
        k=7,
        timesteps=None
    )

if __name__ == '__main__':
    main()