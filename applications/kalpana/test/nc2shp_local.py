from kalpana.export import nc2shp

## path of the adcirc maxele output file, must be a netcdf file
ncFile = r'/mnt/host/maxele.63.nc' 

## name of the maxele variable to downscale. Always 'zeta_max' for downscaling
var = 'zeta_max'

## Contour levels. Min, Max and Step. Max IS included as in np.arange method. Values must be in vUnitOut vertical unit.
## from 0 to 3 meters (included) every 0.5
levels = [0, 5.5, 0.5]

## 'polyline' or 'polygon'
## we are creating polygons in this example
conType = 'polygon'

## complete path of the output file (*.shp or *.gpkg)
pathOut = '/mnt/host/contours.gpkg'

## coordinate system of the output shapefile
epsgOut = 4326  # output in latitude and longitude, based on downscaling DEM

## input and output vertical units. For the momment only supported 'm' and 'ft'  
vUnitIn = 'm' ## Default 'm'
vUnitOut = 'm' ## Default 'ft'

## coordinate system of the adcirc input.
## Default is 4326 since ADCIRC uses latitude and longitude
epsgIn = 4326  

## complete path of the subdomain polygon kml or shapelfile, or list with the
## upper-left x, upper-left y, lower-right x and lower-right y coordinates. 
## the crs must be the same of the adcirc input file. 
subDomain = None  ## Default None

## True for export the mesh geodataframe and also save it as a shapefile. 
## for this example we are only exporting the contours, not the mesh.
exportMesh = False  ## Default False

## file name of the output mesh shapefile. Default None
meshName = None  ## Default None

## full path of the pickle file with the vertical difference between datums for each mesh node. 
dzFile = None  ## Default None

## threshold for using nearest neighbor interpolation to change datum. Points below this value won't be changed.
zeroDif = -20  ## Default -20

## threshold to define the percentage of the dz given by the spatial interpolation to be applied.
maxDif = -5

## distance threshold for limiting the inverse distance-weighted (IDW) interpolation
distThreshold = 0.5

## number of points return in the kdtree query
k = 7

## timesteps to extract if working with a time-varying ADCIRC output file
timesteps = None

gdf = nc2shp(
    ncFile,
    var,
    levels,
    conType,
    pathOut,
    epsgOut,
    vUnitOut=vUnitOut,
    vUnitIn=vUnitIn,
    epsgIn=epsgIn,
    subDomain=subDomain,
    exportMesh=exportMesh,
    meshName=meshName,
    dzFile=dzFile,
    zeroDif=zeroDif,
    maxDif=maxDif,
    distThreshold=distThreshold,
    k=k,
    timesteps=timesteps
)