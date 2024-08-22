import os

from qgis.utils import iface
from qgis.core import QgsBrowserModel
from qgis.core import QgsMessageLog

# add the users pwd and work/home  as it will be hard for user to find it in the Browser
new_favorite_directory = os.getcwd()
work_directory = os.environ['STOCKYARD']
scratch_directory = os.environ['SCRATCH']

base_directory = os.path.dirname(new_favorite_directory)

browser_model = iface.browserModel()

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
        if os.path.normpath(new_favorite_directory) not in existing_favorites:
            browser_model.addFavoriteDirectory(new_favorite_directory)
        if os.path.normpath(work_directory) not in existing_favorites:
            browser_model.addFavoriteDirectory(work_directory)
        if os.path.normpath(scratch_directory) not in existing_favorites:
            browser_model.addFavoriteDirectory(scratch_directory)

    except Exception as e:
        QgsMessageLog.logMessage(f"Error adding new favorites: {str(e)}", level=QgsMessageLog.CRITICAL)


iface.initializationCompleted.connect(setup_favorites)
