from kalpana.downscaling import runStatic
import os

# Accessing environment variables
input_directory = os.environ['_tapisExecSystemInputDir']
output_directory = os.environ['_tapisExecSystemOutputDir']

runStatic(
    f"{input_directory}/input/maxele.63.nc", # ncFile
    [0, 6, 0.5], # levels
    6346, # epsgOut
    f"{output_directory}/downscaling/downscaling.shp", # pathOut
    8.3, # grassVer
    r"{input_directory}", # pathRasFiles
    r"NC_CoNED_subset_100m.tif", # rasterFiles
    r"NC_CoNED_subset_100m_mesh.tif", # meshFile
    epsgIn=4326,
    vUnitIn="m",
    vUnitOut="m",
    var="zeta_max",
    conType="polygon",
    subDomain=f"{input_directory}/input/NC_CoNED_subset_100m.tif",
    epsgSubDom=6346,
    exportMesh=True,
    dzFile=f"{input_directory}/input/dzDaums_noaaTideGauges_msl_navd88.csv",
    zeroDif=-20,
    maxDif=-5,
    distThreshold=0.5,
    k=7,
    nameGrassLocation=None,
    createGrassLocation=True,
    createLocMethod="from_raster",
    attrCol="zMean",
    repLenGrowing=1.0,
    compAdcirc2dem=True,
    floodDepth=False,
    ras2vec=False,
    exportOrg=False,
    leveesFile=None,
    finalOutToLatLon=False
)