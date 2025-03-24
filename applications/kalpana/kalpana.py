import sys
from pathlib import Path
import numpy as np
import netCDF4
import matplotlib.tri as tri
import matplotlib.pyplot as plt
from shapely.geometry import mapping, Polygon, LineString
import fiona
import click
from rich_click import RichCommand, RichGroup
import rich_click as click
from loguru import logger
from typing import List, Optional

# Configure rich-click
click.rich_click.USE_RICH_MARKUP = True
click.rich_click.SHOW_ARGUMENTS = True
click.rich_click.GROUP_ARGUMENTS_OPTIONS = True
click.rich_click.STYLE_ERRORS_SUGGESTION = "yellow italic"
click.rich_click.ERRORS_SUGGESTION = "Try '--help' for help."

# Define file type configurations
FILE_CONFIGS = {
    'maxele.63.nc': {
        'var_name': 'zeta_max',
        'description': 'Maximum Water Height',
        'default_levels': [0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0],  # meters
        'units': 'meters'
    },
    'maxvel.63.nc': {
        'var_name': 'vel_max',
        'description': 'Maximum Water Velocity',
        'default_levels': [0, 0.5, 1.0, 1.5, 2.0, 2.5, 3.0],  # m/s
        'units': 'm/s'
    },
    'maxwvel.63.nc': {
        'var_name': 'wind_max',
        'description': 'Maximum Wind Velocity',
        'default_levels': [0, 10, 20, 30, 40, 50, 60, 70, 80, 90],  # m/s
        'units': 'm/s'
    }
}

def setup_logging(log_file: Path):
    """Configure logging to both file and stdout."""
    logger.remove()  # Remove default handler
    
    # Add stdout handler with custom format
    logger.add(
        sys.stdout,
        format="<green>{time:YYYY-MM-DD HH:mm:ss}</green> | <level>{level: <8}</level> | <cyan>{name}</cyan>:<cyan>{function}</cyan>:<cyan>{line}</cyan> - <level>{message}</level>",
        level="INFO"
    )
    
    # Add file handler with more detailed format
    logger.add(
        log_file,
        format="{time:YYYY-MM-DD HH:mm:ss} | {level: <8} | {name}:{function}:{line} | {message}",
        level="DEBUG",
        rotation="10 MB"
    )

def analyze_data_range(var: np.ndarray) -> tuple[float, float]:
    """
    Analyze the data range in the variable, excluding masked or fill values.
    
    Returns:
        tuple[float, float]: (min_value, max_value)
    """
    # If it's a masked array, get the unmasked values
    if hasattr(var, 'mask'):
        valid_data = var.compressed()  # Gets only unmasked data
    else:
        valid_data = var[var > -99]  # Filter out fill values

    return float(np.min(valid_data)), float(np.max(valid_data))

def suggest_contour_levels(min_val: float, max_val: float, target_intervals: int = 10) -> tuple[float, float, float]:
    """
    Suggest reasonable contour levels based on data range.
    
    Args:
        min_val: Minimum value in data
        max_val: Maximum value in data
        target_intervals: Desired number of intervals
    
    Returns:
        tuple[float, float, float]: (suggested_min, suggested_max, suggested_increment)
    """
    data_range = max_val - min_val
    
    # Round min/max to reasonable values
    magnitude = 10 ** np.floor(np.log10(data_range / target_intervals))
    suggested_increment = magnitude
    
    # Try standard increments (1, 2, 2.5, 5, 10) × magnitude
    standard_increments = [1, 2, 2.5, 5, 10]
    for inc in standard_increments:
        if data_range / (inc * magnitude) < target_intervals:
            suggested_increment = inc * magnitude
            break
    
    suggested_min = np.floor(min_val / suggested_increment) * suggested_increment
    suggested_max = np.ceil(max_val / suggested_increment) * suggested_increment
    
    return suggested_min, suggested_max, suggested_increment

def suggest_smart_contour_levels(var: np.ndarray, target_intervals: int = 20) -> List[float]:
    """
    Suggests contour levels based on the actual distribution of data values.
    Uses a combination of percentile-based and clustering approaches to identify
    meaningful breaks in the data. Ensures strictly increasing float values.
    
    Args:
        var: Input data array (can be masked)
        target_intervals: Desired number of intervals (default=10)
    
    Returns:
        List[float]: Suggested contour levels (strictly increasing)
    """
    # Get valid data (handle masked arrays and fill values)
    if hasattr(var, 'mask'):
        valid_data = var.compressed()
    else:
        valid_data = var[var > -99]
    
    # Get basic statistics
    min_val = float(np.min(valid_data))
    max_val = float(np.max(valid_data))
    
    # Calculate a reasonable number of divisions based on the data range
    data_range = max_val - min_val
    if data_range > 100:
        precision = 0
    elif data_range > 10:
        precision = 1
    elif data_range > 1:
        precision = 2
    else:
        precision = 3
    
    # Create evenly spaced intervals as a base
    base_intervals = np.linspace(min_val, max_val, target_intervals)
    base_intervals = np.round(base_intervals, precision)
    
    # Add data-driven breaks using percentiles
    percentiles = [25, 50, 75]  # Add quartiles
    percentile_values = np.percentile(valid_data, percentiles)
    percentile_values = np.round(percentile_values, precision)
    
    # Combine all potential break points and ensure uniqueness
    all_breaks = np.concatenate([base_intervals, percentile_values])
    all_breaks = np.unique(all_breaks)  # Remove duplicates
    all_breaks = np.round(all_breaks, precision)  # Round again after combining
    
    # Sort and convert to list of standard Python floats
    final_breaks = sorted(float(x) for x in all_breaks)
    
    # Ensure we don't exceed target number of intervals
    if len(final_breaks) > target_intervals:
        # Use linear interpolation to reduce number of breaks
        indices = np.linspace(0, len(final_breaks) - 1, target_intervals).astype(int)
        final_breaks = [final_breaks[i] for i in indices]
    
    # Add min and max if they're not already included
    if final_breaks[0] > min_val:
        final_breaks.insert(0, float(np.round(min_val, precision)))
    if final_breaks[-1] < max_val:
        final_breaks.append(float(np.round(max_val, precision)))
    
    # Ensure strict monotonicity with a small epsilon
    eps = 10**(-precision) / 2
    result = []
    prev = None
    for val in final_breaks:
        if prev is None or val > prev + eps:
            result.append(val)
            prev = val
    
    return result

def validate_smart_contour_levels(levels: List[float], var: np.ndarray) -> bool:
    """
    Validates if the suggested contour levels provide a good representation
    of the data distribution.
    
    Args:
        levels: List of contour levels
        var: Input data array
    
    Returns:
        bool: True if levels are valid, False otherwise
    """
    if hasattr(var, 'mask'):
        valid_data = var.compressed()
    else:
        valid_data = var[var > -99]
    
    # Check if we have enough levels
    if len(levels) < 3:
        return False
    
    # Check if levels span the data range
    data_min, data_max = np.min(valid_data), np.max(valid_data)
    if levels[0] > data_min or levels[-1] < data_max:
        return False
    
    # Check distribution of data points in each interval
    hist, _ = np.histogram(valid_data, bins=levels)
    
    # No interval should have more than 50% of the data points
    if np.max(hist) > 0.5 * len(valid_data):
        return False
    
    # No interval should be empty (unless it's at the extremes)
    if np.any(hist[1:-1] == 0):
        return False
    
    return True

def validate_contour_levels(levels: List[float], data_min: float, data_max: float) -> bool:
    """
    Validate if contour levels are reasonable for the data range.
    
    Returns:
        bool: True if levels are reasonable, False otherwise
    """
    if not levels:
        return False
    
    levels_min, levels_max = min(levels), max(levels)
    
    # Check if contours span at least 50% of the data range
    data_range = data_max - data_min
    levels_range = levels_max - levels_min
    
    if levels_range < 0.5 * data_range:
        return False
    
    # Check if we have too many or too few levels
    if len(levels) < 3 or len(levels) > 20:
        return False
    
    # Check if the increment is reasonable (not too small or large)
    increments = np.diff(sorted(levels))
    median_increment = np.median(increments)
    if median_increment < data_range / 100 or median_increment > data_range / 2:
        return False
    
    return True

import numpy as np
from typing import Optional, Tuple

def get_data_bounds(lon: np.ndarray, lat: np.ndarray) -> Tuple[float, float, float, float]:
    """
    Get the bounding box of the data.
    
    Args:
        lon: Longitude values
        lat: Latitude values
    
    Returns:
        Tuple[float, float, float, float]: (min_lon, max_lon, min_lat, max_lat)
    """
    return float(np.min(lon)), float(np.max(lon)), float(np.min(lat)), float(np.max(lat))

def validate_bbox(
    bbox: Tuple[float, float, float, float],
    data_bounds: Tuple[float, float, float, float]
) -> bool:
    """
    Validate if the bounding box overlaps with data bounds.
    
    Args:
        bbox: (min_lon, max_lon, min_lat, max_lat) of requested region
        data_bounds: (min_lon, max_lon, min_lat, max_lat) of data
        
    Returns:
        bool: True if valid, False if no overlap
    """
    min_lon, max_lon, min_lat, max_lat = bbox
    data_min_lon, data_max_lon, data_min_lat, data_max_lat = data_bounds
    
    # Check if bounding boxes overlap
    lon_overlap = (min_lon <= data_max_lon) and (max_lon >= data_min_lon)
    lat_overlap = (min_lat <= data_max_lat) and (max_lat >= data_min_lat)
    
    return lon_overlap and lat_overlap

def filter_by_bbox(
    lon: np.ndarray,
    lat: np.ndarray,
    var: np.ndarray,
    nv: np.ndarray,
    bbox: Optional[Tuple[float, float, float, float]] = None
) -> Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]:
    """
    Filter data by bounding box.
    
    Args:
        lon: Longitude values
        lat: Latitude values
        var: Variable data
        nv: Element connectivity
        bbox: Optional (min_lon, max_lon, min_lat, max_lat)
    
    Returns:
        Tuple[np.ndarray, np.ndarray, np.ndarray, np.ndarray]: Filtered lon, lat, var, nv
    """
    if bbox is None:
        return lon, lat, var, nv
        
    min_lon, max_lon, min_lat, max_lat = bbox
    
    # Create mask for points within bbox
    mask = ((lon >= min_lon) & (lon <= max_lon) & 
            (lat >= min_lat) & (lat <= max_lat))
    
    # Get indices of points within bbox
    valid_indices = np.where(mask)[0]
    
    # Create mapping from old to new indices
    index_map = np.full(len(lon), -1)
    index_map[valid_indices] = np.arange(len(valid_indices))
    
    # Filter points and variables
    filtered_lon = lon[mask]
    filtered_lat = lat[mask]
    filtered_var = var[mask] if var.shape == lon.shape else var
    
    # Filter elements (triangles)
    # Keep only elements where all vertices are within bbox
    valid_elements_mask = np.all(np.isin(nv, valid_indices), axis=1)
    filtered_nv = nv[valid_elements_mask]
    
    # Update connectivity indices to match new filtered points
    filtered_nv = index_map[filtered_nv]
    
    return filtered_lon, filtered_lat, filtered_var, filtered_nv

def create_contours(
    filename: Path,
    output_name: Path,
    poly_type: str = 'polygon',
    levels: Optional[List[float]] = None,
    use_smart_contours: bool = True,
    bbox: Optional[Tuple[float, float, float, float]] = None
) -> None:
    """
    Create contours from ADCIRC output files and export as shapefiles.
    
    Args:
        filename: Path to the input file
        output_name: Path for output shapefile
        poly_type: Type of contour ('polygon' or 'polyline')
        levels: Optional list of contour levels
        use_smart_contours: Whether to use smart contour generation
        bbox: Optional (min_lon, max_lon, min_lat, max_lat) for region filtering
    """
    logger.info(f"Processing file: {filename}")
    logger.info(f"Output will be saved to: {output_name}.shp")
    
    base_filename = filename.name
    
    if base_filename not in FILE_CONFIGS:
        err_msg = f"Unsupported file type. Must be one of: {', '.join(FILE_CONFIGS.keys())}"
        logger.error(err_msg)
        raise ValueError(err_msg)
    
    config = FILE_CONFIGS[base_filename]
    logger.debug(f"Using configuration for {config['description']}")
    
    try:
        # Read ADCIRC output file
        logger.debug(f"Reading netCDF file: {filename}")
        nc = netCDF4.Dataset(filename)
        
        # Extract all required variables first
        logger.debug("Extracting variables from netCDF file")
        lon = nc.variables['x'][:]
        lat = nc.variables['y'][:]
        nv = nc.variables['element'][:,:] - 1
        var = nc.variables[config['var_name']][:]
        
        # Get and log data bounds
        data_bounds = get_data_bounds(lon, lat)
        logger.info(f"Data bounds: lon({data_bounds[0]:.4f}, {data_bounds[1]:.4f}), "
                   f"lat({data_bounds[2]:.4f}, {data_bounds[3]:.4f})")
        
        # If bbox specified, validate and filter
        if bbox is not None:
            if not validate_bbox(bbox, data_bounds):
                logger.warning("Specified bounding box has no overlap with data bounds!")
                logger.warning("Processing will continue but may produce empty or unexpected results")
            
            logger.info(f"Filtering data to bounding box: lon({bbox[0]:.4f}, {bbox[1]:.4f}), "
                       f"lat({bbox[2]:.4f}, {bbox[3]:.4f})")
            lon, lat, var, nv = filter_by_bbox(lon, lat, var, nv, bbox)
            
            if len(lon) == 0:
                raise ValueError("No data points remain after applying bounding box filter")
            
            logger.info(f"Filtered to {len(lon)} points and {len(nv)} elements")

        # If no levels provided, generate them
        if levels is None:
            if use_smart_contours:
                levels = suggest_smart_contour_levels(var)
                levels_str = ",".join(f"{x:.2f}" for x in levels)
                logger.info(f"Using smart contour levels: {levels_str}")
                logger.info(f"To use these levels in future runs: --levels {levels_str}")
            else:
                suggested_min, suggested_max, suggested_inc = suggest_contour_levels(data_min, data_max)
                levels = generate_contour_levels_from_range(suggested_min, suggested_max, suggested_inc)
                levels_str = ",".join(f"{x:.2f}" for x in levels)
                logger.info(f"Using regular contour levels: {levels_str}")
                logger.info(f"To use these levels in future runs: --levels {levels_str}")
        else:
            # Validate provided levels
            if not validate_contour_levels(levels, data_min, data_max):
                suggested_min, suggested_max, suggested_inc = suggest_contour_levels(data_min, data_max)
                suggested_levels = generate_contour_levels_from_range(suggested_min, suggested_max, suggested_inc)
                suggested_levels_str = ",".join(f"{x:.2f}" for x in suggested_levels)
                logger.warning(f"Provided contour levels may not be optimal for this data range.")
                logger.warning(f"To use suggested levels in future runs: --levels {suggested_levels_str}")
                logger.warning(f"Or use suggested range: --range {suggested_min:.2f},{suggested_max:.2f},{suggested_inc:.2f}")
                
                # Just log the warning - no user input required
                logger.warning(f"Continuing with provided levels, but they may not provide optimal visualization")
                logger.warning(f"Consider using the suggested range in your next run: --range {suggested_min},{suggested_max},{suggested_inc}")
        
        # Handle masked values after analyzing range
        if hasattr(var, 'mask'):
            logger.debug("Replacing masked values with -100")
            var = var.filled(-100)

        # Create triangulation
        logger.debug("Creating triangulation")
        triang = tri.Triangulation(lon, lat, triangles=nv)
        
        # Generate contours
        logger.info(f"Generating {poly_type} contours")
        if poly_type == 'polygon':
            contour = plt.tricontourf(triang, var, levels=levels)
        else:  # polyline
            contour = plt.tricontour(triang, var, levels=levels)

        # Set up shapefile schema
        crs = {'no_defs': True, 'ellps': 'WGS84', 'datum': 'WGS84', 'proj': 'longlat'}
    
        # Update the schema definition for better QGIS compatibility
        if poly_type == 'polygon':
            schema = {
                'geometry': 'Polygon',
                'properties': {
                    'value': 'float',  # Single value for easier styling
                    'min_val': 'float',
                    'max_val': 'float',
                    'units': 'str'
                }
            }
        else:  # polyline
            schema = {
                'geometry': 'LineString',
                'properties': {
                    'value': 'float',
                    'units': 'str'
                }
            }

        # Modified shapefile writing section
        logger.info(f"Writing shapefile to {output_name}.shp")
        with fiona.open(f"{output_name}.shp", 'w', 'ESRI Shapefile', schema, crs=crs) as output:
            if poly_type == 'polygon':
                for i, collection in enumerate(contour.collections):
                    vmin, vmax = contour.levels[i:i+2]
                    vavg = (vmin + vmax) / 2  # Average value for styling
                    
                    for path in collection.get_paths():
                        for polygon in path.to_polygons():
                            if polygon.shape[0] >= 3:  # Only write valid polygons
                                poly = Polygon(polygon)
                                if poly.is_valid:
                                    output.write({
                                        'geometry': mapping(poly),
                                        'properties': {
                                            'value': float(vavg),  # Use average for primary styling
                                            'min_val': float(vmin),
                                            'max_val': float(vmax),
                                            'units': config['units']
                                        }
                                    })
            else:  # polyline
                for i, collection in enumerate(contour.collections):
                    value = contour.levels[i]
                    
                    for path in collection.get_paths():
                        if len(path.vertices) > 1:
                            line = LineString(path.vertices)
                            output.write({
                                'geometry': mapping(line),
                                'properties': {
                                    'value': float(value),
                                    'units': config['units']
                                }
                            })
        logger.success(f"Successfully created shapefile: {output_name}.shp")

        # After successful shapefile creation, generate the QML
        try:
            data_min = min(levels)
            data_max = max(levels)
            generate_qml_style(output_name, data_min, data_max, config['units'])
            logger.success(f"Successfully created shapefile and style: {output_name}.shp")
        except Exception as e:
            logger.warning(f"Shapefile created but style generation failed: {e}")
            logger.success(f"Successfully created shapefile: {output_name}.shp")
            
    except Exception as e:
        logger.exception(f"Error processing file: {e}")
        raise
    finally:
        nc.close()
        plt.close()
        logger.debug("Cleaned up resources")
            
def generate_qml_style(output_name: Path, min_val: float, max_val: float, units: str) -> None:
    """
    Generate a QGIS Layer Style File (.qml) following QGIS default styling conventions.
    
    Args:
        output_name: Base name for the output files
        min_val: Minimum value in the dataset
        max_val: Maximum value in the dataset 
        units: Units for display
    """
    # Calculate optimal number of classes - use "Pretty Breaks" logic
    range_size = max_val - min_val
    # Choose an appropriate number of classes based on the data range
    if range_size <= 0.1:
        n_classes = 5
    else:
        n_classes = 7
    
    # Generate nice round numbers for breaks
    interval = range_size / n_classes
    magnitude = 10 ** np.floor(np.log10(interval))
    scaled_interval = interval / magnitude
    if scaled_interval < 1.5:
        nice_interval = magnitude
    elif scaled_interval < 3:
        nice_interval = 2 * magnitude
    elif scaled_interval < 7:
        nice_interval = 5 * magnitude
    else:
        nice_interval = 10 * magnitude

    # Create ranges with nice round numbers
    ranges = []
    current = min_val
    while current < max_val:
        next_val = min(current + nice_interval, max_val)
        ranges.append((current, next_val))
        current = next_val

    # Colors from QGIS Blues color ramp (from lightest to darkest)
    colors = [
        "247,251,255",
        "215,230,245",
        "175,209,231",
        "115,178,216",
        "62,142,196",
        "22,99,170",
        "8,48,107"
    ]

    # If we have fewer ranges than colors, trim the color list
    colors = colors[:len(ranges)]

    # Generate the QML content
    qml_content = f'''<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis labelsEnabled="0" styleCategories="AllStyleCategories" minScale="100000000" maxScale="0" simplifyMaxScale="1" simplifyAlgorithm="0" symbologyReferenceScale="-1" readOnly="0" hasScaleBasedVisibilityFlag="0" simplifyDrawingTol="1" simplifyLocal="1" simplifyDrawingHints="1" version="3.36.2-Maidenhead">
  <renderer-v2 symbollevels="0" forceraster="0" enableorderby="0" graduatedMethod="GraduatedColor" attr="value" type="graduatedSymbol" referencescale="-1">
    <ranges>'''

    # Add ranges
    for i, ((lower, upper), color) in enumerate(zip(ranges, colors)):
        qml_content += f'''
      <range render="true" lower="{lower:.12f}" label="{lower:.3f} - {upper:.3f}" symbol="{i}" uuid="{{00000000-0000-0000-0000-{i:012d}}}" upper="{upper:.12f}"/>'''

    qml_content += '''
    </ranges>
    <symbols>'''

    # Add symbols
    for i, color in enumerate(colors):
        qml_content += f'''
      <symbol is_animated="0" force_rhr="0" alpha="1" frame_rate="10" type="fill" name="{i}" clip_to_extent="1">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer pass="0" enabled="1" class="SimpleFill" locked="0">
          <Option type="Map">
            <Option type="QString" value="3x:0,0,0,0,0,0" name="border_width_map_unit_scale"/>
            <Option type="QString" value="{color},255" name="color"/>
            <Option type="QString" value="bevel" name="joinstyle"/>
            <Option type="QString" value="0,0" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MM" name="offset_unit"/>
            <Option type="QString" value="35,35,35,255" name="outline_color"/>
            <Option type="QString" value="solid" name="outline_style"/>
            <Option type="QString" value="0.26" name="outline_width"/>
            <Option type="QString" value="MM" name="outline_width_unit"/>
            <Option type="QString" value="solid" name="style"/>
          </Option>
        </layer>
      </symbol>'''

    qml_content += '''
    </symbols>
    <source-symbol>
      <symbol is_animated="0" force_rhr="0" alpha="1" frame_rate="10" type="fill" name="0" clip_to_extent="1">
        <data_defined_properties>
          <Option type="Map">
            <Option type="QString" value="" name="name"/>
            <Option name="properties"/>
            <Option type="QString" value="collection" name="type"/>
          </Option>
        </data_defined_properties>
        <layer pass="0" enabled="1" class="SimpleFill" locked="0">
          <Option type="Map">
            <Option type="QString" value="3x:0,0,0,0,0,0" name="border_width_map_unit_scale"/>
            <Option type="QString" value="243,166,178,255" name="color"/>
            <Option type="QString" value="bevel" name="joinstyle"/>
            <Option type="QString" value="0,0" name="offset"/>
            <Option type="QString" value="3x:0,0,0,0,0,0" name="offset_map_unit_scale"/>
            <Option type="QString" value="MM" name="offset_unit"/>
            <Option type="QString" value="35,35,35,255" name="outline_color"/>
            <Option type="QString" value="solid" name="outline_style"/>
            <Option type="QString" value="0.26" name="outline_width"/>
            <Option type="QString" value="MM" name="outline_width_unit"/>
            <Option type="QString" value="solid" name="style"/>
          </Option>
        </layer>
      </symbol>
    </source-symbol>
    <colorramp type="gradient" name="[source]">
      <Option type="Map">
        <Option type="QString" value="247,251,255,255" name="color1"/>
        <Option type="QString" value="8,48,107,255" name="color2"/>
        <Option type="QString" value="0" name="discrete"/>
        <Option type="QString" value="gradient" name="rampType"/>
      </Option>
    </colorramp>
    <classificationMethod id="Pretty">
      <symmetricMode enabled="0" astride="0" symmetrypoint="0"/>
      <labelFormat trimtrailingzeroes="0" labelprecision="3" format="%1 - %2"/>
      <parameters>
        <Option/>
      </parameters>
      <extraInformation/>
    </classificationMethod>
    <rotation/>
    <sizescale/>
  </renderer-v2>
  <customproperties>
    <Option type="Map">
      <Option type="int" value="0" name="embeddedWidgets/count"/>
      <Option name="variableNames"/>
      <Option name="variableValues"/>
    </Option>
  </customproperties>
  <blendMode>0</blendMode>
  <featureBlendMode>0</featureBlendMode>
  <layerOpacity>1</layerOpacity>
</qgis>'''

    # Write the QML file
    qml_path = output_name.with_suffix('.qml')
    with open(qml_path, 'w') as f:
        f.write(qml_content)
    logger.info(f"Created QGIS style file: {qml_path}")
    
def generate_contour_levels_from_range(min_val: float, max_val: float, increment: float) -> List[float]:
    """Generate contour levels from a range specification."""
    levels = []
    current = min_val
    while current <= max_val:
        levels.append(current)
        current += increment
    return levels

# Update the CLI command
@click.command(cls=RichCommand)
@click.option(
    '-f', '--filename',
    type=click.Path(exists=True, path_type=Path),
    required=True,
    help="ADCIRC output file (maxele.63.nc, maxvel.63.nc, or maxwvel.63.nc)"
)
@click.option(
    '-t', '--type',
    'poly_type',
    type=click.Choice(['polygon', 'polyline'], case_sensitive=False),
    default='polygon',
    help="Output type: polygon or polyline",
    show_default=True
)
@click.option(
    '-o', '--output',
    'output_name',
    type=click.Path(path_type=Path),
    default=Path('contours'),
    help="Output shapefile name (without extension)",
    show_default=True
)
@click.option(
    '-l', '--levels',
    help="[Optional] Comma-separated list of contour levels (e.g., '0,1,2,3')"
)
@click.option(
    '-r', '--range',
    'contour_range',
    help="[Optional] Contour range as 'min,max,increment' (e.g., '0,10,0.5')"
)
@click.option(
    '--smart/--regular',
    'use_smart_contours',
    default=True,
    help="Use smart contour level generation when no levels specified",
    show_default=True
)
@click.option(
    '--auto-levels/--no-auto-levels',
    default=True,
    help="Automatically generate contour levels if none specified",
    show_default=True
)
@click.option(
    '-b', '--bbox',
    help="Bounding box as 'min_lon,max_lon,min_lat,max_lat' (e.g., '-95,-90,25,30')"
)
@click.option(
    '--log-file',
    type=click.Path(path_type=Path),
    default=Path('kalpana.log'),
    help="Log file path",
    show_default=True
)
def main(
    filename: Path, 
    poly_type: str, 
    output_name: Path, 
    levels: Optional[str], 
    contour_range: Optional[str],
    use_smart_contours: bool,
    auto_levels: bool,
    bbox: Optional[str],
    log_file: Path
):
    """
    [bold green]Kalpana[/bold green] - ADCIRC Output Processor
    
    Creates contour polygons or polylines from ADCIRC output files and exports them as shapefiles.
    
    Supported file types:
    - maxele.63.nc (Maximum Water Height)
    - maxvel.63.nc (Maximum Water Velocity)
    - maxwvel.63.nc (Maximum Wind Velocity)

    Contour levels can be specified in three ways:
    1. Automatic (default): Uses smart contour generation based on data distribution
    2. Using --levels with comma-separated values (e.g., --levels "0,1,2,3")
    3. Using --range with min,max,increment values (e.g., --range "0,10,0.5")
    
    Smart contour generation (default) analyzes the data distribution to create
    meaningful breaks. Use --regular for evenly-spaced contours instead.

    Examples:
    \b
    # Use smart contour generation (default):
    kalpana -f maxele.63.nc -o flood_contours
    
    # Use regular (evenly-spaced) contours:
    kalpana -f maxele.63.nc -o flood_contours --regular
    
    # Specify exact contour levels:
    kalpana -f maxele.63.nc -o flood_contours -l "0,0.5,1.0,1.5,2.0"
    
    # Specify contour range:
    kalpana -f maxwvel.63.nc -o wind_contours -r "0,50,10"
    """
    # Set up logging
    setup_logging(log_file)
    
    try:
        # Parse bounding box if specified
        bbox_tuple = None
        if bbox:
            try:
                bbox_tuple = tuple(map(float, bbox.split(',')))
                if len(bbox_tuple) != 4:
                    raise ValueError
                logger.info(f"Using bounding box filter: {bbox_tuple}")
            except ValueError:
                logger.error("Invalid bounding box format")
                raise click.BadParameter(
                    "Bounding box must be specified as 'min_lon,max_lon,min_lat,max_lat'"
                )
        # Handle contour specifications
        contour_levels = None
        
        if levels and contour_range:
            raise click.BadParameter("Cannot specify both --levels and --range. Please use only one.")
        
        if levels:
            try:
                contour_levels = [float(x.strip()) for x in levels.split(',')]
                logger.info(f"Using custom contour levels: {contour_levels}")
            except ValueError:
                logger.error("Invalid contour levels format")
                raise click.BadParameter("Contour levels must be comma-separated numbers")
        
        elif contour_range:
            try:
                min_val, max_val, increment = map(float, contour_range.split(','))
                contour_levels = generate_contour_levels_from_range(min_val, max_val, increment)
                logger.info(f"Generated contour levels from range: {contour_levels}")
            except ValueError:
                logger.error("Invalid contour range format")
                raise click.BadParameter("Contour range must be specified as 'min,max,increment'")
        
        elif not auto_levels:
            logger.error("No contour levels specified and automatic generation is disabled")
            raise click.BadParameter("Must specify contour levels when --no-auto-levels is used")

        create_contours(
            filename,
            output_name,
            poly_type,
            contour_levels,
            use_smart_contours,
            bbox_tuple
        )
        
    except Exception as e:
        logger.exception("Process failed")
        raise click.ClickException(str(e))

if __name__ == "__main__":
    main()
