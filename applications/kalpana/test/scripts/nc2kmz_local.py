from kalpana.export import nc2kmz

nc2kmz(
    r"/mnt/host/maxwvel.63.nc", # ncFile
    "wind_max", # var
    [0, 5.5, 0.5], # levels
    "polygon", # conType
    4326, # epsg
    r"/mnt/host/contours.kmz", # pathOut
    vUnitIn='m',
    vUnitOut='m',
    vDatumIn='tss',
    vDatumOut='tss',
    subDomain=None,
    overlay=True,
    logoFile='logo.png',
    colorbarFile='tempColorbar.jpg',
    cmap='viridis',
    thresVertices=20_000,
    dzFile=None,
    zeroDif=-20
)