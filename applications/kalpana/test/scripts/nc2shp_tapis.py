from kalpana.export import nc2shp
import os

# Accessing environment variables
input_directory = os.environ['_tapisExecSystemInputDir']
output_directory = os.environ['_tapisExecSystemOutputDir']

gdf = nc2shp(
    f"{input_directory}/input", # ncFile
    "zeta_max", # var
    [0, 5.5, 0.5], # levels
    "polygon", # conType
    f"{output_directory}/output.gpkg", # pathOut
    4326, # epsgOut
    vUnitOut="m",
    vUnitIn="m",
    epsgIn=4326,
    subDomain=None,
    exportMesh=None,
    meshName=None,
    dzFile=None,
    zeroDif=-20,
    maxDif=-5,
    distThreshold=0.7,
    k=7,
    timesteps=None
)