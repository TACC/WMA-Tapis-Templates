from kalpana.export import nc2shp

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