import os

from qgis.utils import iface
from qgis.core import QgsExpressionContextUtils, QgsMessageLog

# Define directories
new_favorite_directory = os.getcwd()

mydata = os.path.join(os.environ['HOME'], 'mydata')
projects = os.path.join(os.environ['HOME'], 'projects')
community = os.path.join(os.environ['HOME'], 'community')

base_directory = os.path.dirname(new_favorite_directory)


def setup_favorites():
    browser_model = iface.browserModel()

    # Try to remove any previously added directories
    try:
        favorite_index = browser_model.findPath("favorites:")
        to_be_removed = []
        for i in range(browser_model.rowCount(favorite_index)):
            index = browser_model.index(i, 0, favorite_index)
            path = index.data()
            dirname = os.path.dirname(path)
            if base_directory == dirname or path in favorites_map:
                to_be_removed.append(index)
        for remove_index in to_be_removed:
            browser_model.removeFavorite(remove_index)
    except Exception as e:
        QgsMessageLog.logMessage(f"Error removing old favorites: {str(e)}", level=QgsMessageLog.CRITICAL)

    # Add the new directories as favorites
    try:
        
        browser_model.addFavoriteDirectory(mydata)
        browser_model.addFavoriteDirectory(projects)
        browser_model.addFavoriteDirectory(community)
    except Exception as e:
        QgsMessageLog.logMessage(f"Error adding new favorites: {str(e)}", level=QgsMessageLog.CRITICAL)


def customize_title():
    try:
        version = QgsExpressionContextUtils.globalScope().variable('qgis_version')
        title = iface.mainWindow().windowTitle()
        iface.mainWindow().setWindowTitle(f'{title} | {version}')
    except Exception as e:
        QgsMessageLog.logMessage(f"Error customizing window title: {str(e)}", level=QgsMessageLog.CRITICAL)


# Connect the functions to QGIS startup
iface.initializationCompleted.connect(setup_favorites)
iface.initializationCompleted.connect(customize_title)
