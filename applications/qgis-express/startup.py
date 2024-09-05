import os
from qgis.utils import iface
from qgis.core import QgsExpressionContextUtils, QgsMessageLog

# Define directories
new_favorite_directory = os.environ['TAPIS_WORKING_DIR']

mydata = os.path.join(new_favorite_directory, 'MyData')
nees = os.path.join(new_favorite_directory, 'NEES')
nheriPublished = os.path.join(new_favorite_directory, 'NHERI-Published')
community = os.path.join(new_favorite_directory, 'CommunityData')
myprojects = os.path.join(new_favorite_directory, 'MyProjects')

def setup_favorites():
    browser_model = iface.browserModel()

    # Delete all existing favorites
    favorite_index = browser_model.findPath("favorites:")
    if favorite_index.isValid():
        to_be_removed = []
        for i in range(browser_model.rowCount(favorite_index)):
            index = browser_model.index(i, 0, favorite_index)
            to_be_removed.append(index)
        
        for remove_index in to_be_removed:
            browser_model.removeFavorite(remove_index)

    # Add the new directories as favorites
    try:
        browser_model.addFavoriteDirectory(mydata)
        browser_model.addFavoriteDirectory(nees)
        browser_model.addFavoriteDirectory(nheriPublished)
        browser_model.addFavoriteDirectory(community)
        browser_model.addFavoriteDirectory(myprojects)
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
