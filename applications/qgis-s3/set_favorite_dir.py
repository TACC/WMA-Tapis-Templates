import os
from qgis.utils import iface
from qgis.core import QgsBrowserModel
from qgis.core import QgsMessageLog

# Add the user's pwd and work/home as it will be hard for the user to find it in the Browser
new_favorite_directory = os.getcwd()
work_directory = os.environ['STOCKYARD']
scratch_directory = os.environ['SCRATCH']

browser_model = iface.browserModel()

def setup_favorites():
    browser_model = iface.browserModel()

    # Fetch existing favorites
    def fetch_existing_favorites():
        favorite_index = browser_model.findPath("favorites:")
        existing_favorites = []
        for i in range(browser_model.rowCount(favorite_index)):
            index = browser_model.index(i, 0, favorite_index)
            path = os.path.normpath(index.data())
            existing_favorites.append((path, index))
        return existing_favorites

    existing_favorites = fetch_existing_favorites()

    # Remove any favorite that starts with /work or /scratch
    try:
        for path, index in existing_favorites:
            if path.startswith('/work') or path.startswith('/scratch'):
                browser_model.removeFavorite(index)

        # Re-fetch existing favorites after removal
        existing_favorites = fetch_existing_favorites()

        # Add the new directories as favorites if not already present
        if os.path.normpath(new_favorite_directory) not in [fav[0] for fav in existing_favorites]:
            browser_model.addFavoriteDirectory(new_favorite_directory)
        if os.path.normpath(work_directory) not in [fav[0] for fav in existing_favorites]:
            browser_model.addFavoriteDirectory(work_directory)
        if os.path.normpath(scratch_directory) not in [fav[0] for fav in existing_favorites]:
            browser_model.addFavoriteDirectory(scratch_directory)

    except Exception as e:
        QgsMessageLog.logMessage(str(e))


iface.initializationCompleted.connect(setup_favorites)
