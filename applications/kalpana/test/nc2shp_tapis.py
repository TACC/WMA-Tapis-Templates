from kalpana.export import nc2shp
import os

# Accessing environment variables
input_directory = os.environ['_tapisExecSystemInputDir']
output_directory = os.environ['_tapisExecSystemOutputDir']

gdf = nc2shp(
    f"{input_directory}/input",
    "zeta_max",
    [0, 5.5, 0.5],
    "polygon",
    f"{output_directory}/output.gpkg",
    4326,
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
