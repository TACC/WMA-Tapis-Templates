import os
from qgis.utils import iface
from qgis.core import QgsExpressionContextUtils, QgsMessageLog

# Define directories
new_favorite_directory = os.getcwd()

mydata = os.path.join(os.environ['HOME'], 'MyData')
nees = os.path.join(os.environ['HOME'], 'NEES')
nheriPublished = os.path.join(os.environ['HOME'], 'NHERI-Published')
community = os.path.join(os.environ['HOME'], 'CommunityData')
myprojects = os.path.join(os.environ['HOME'], 'MyProjects')

base_directory = os.path.dirname(new_favorite_directory)

def setup_favorites():
    browser_model = iface.browserModel()

    # Fetch existing favorites
    favorite_index = browser_model.findPath("favorites:")
    existing_favorites = set()

    for i in range(browser_model.rowCount(favorite_index)):
        index = browser_model.index(i, 0, favorite_index)
        path = os.path.normpath(index.data())
        existing_favorites.add(path)

    # Add the new directories as favorites if not already present
    try:
        if os.path.normpath(mydata) not in existing_favorites:
            browser_model.addFavoriteDirectory(mydata)
        if os.path.normpath(nees) not in existing_favorites:
            browser_model.addFavoriteDirectory(nees)
        if os.path.normpath(nheriPublished) not in existing_favorites:
            browser_model.addFavoriteDirectory(nheriPublished)
        if os.path.normpath(community) not in existing_favorites:
            browser_model.addFavoriteDirectory(community)
        if os.path.normpath(myprojects) not in existing_favorites:
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
