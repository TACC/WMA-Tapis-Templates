import os

from qgis.utils import iface
from qgis.core import QgsExpressionContextUtils, QgsMessageLog

# Define directories
new_favorite_directory = os.getcwd()

mydata = os.path.join(os.environ['HOME'], 'MyData')
nees = os.path.join(os.environ['HOME'], 'NEES')
nheriPublished = os.path.join(os.environ['HOME'], 'NHERI-Published')
community = os.path.join(os.environ['HOME'], 'CommunityData')

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
            if base_directory == dirname or path in ['MyData', 'NEES', 'NHERI-Published','CommunityData']:
                to_be_removed.append(index)
        for remove_index in to_be_removed:
            browser_model.removeFavorite(remove_index)
    except Exception as e:
        QgsMessageLog.logMessage(f"Error removing old favorites: {str(e)}", level=QgsMessageLog.CRITICAL)

    # Add the new directories as favorites
    try:
        
        browser_model.addFavoriteDirectory(mydata)
        browser_model.addFavoriteDirectory(nees)
        browser_model.addFavoriteDirectory(nheriPublished)
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
