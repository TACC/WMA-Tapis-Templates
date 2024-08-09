import os

from qgis.utils import iface
from qgis.core import QgsBrowserModel
from qgis.core import QgsMessageLog

new_favorite_directory = os.getcwd()
work_directory = os.environ['STOCKYARD']
scratch_directory = os.environ['SCRATCH']

base_directory = os.path.dirname(new_favorite_directory)

browser_model = iface.browserModel()

# try to remove any previously added working/home directories
# (i.e. directories with matching base_directory)
try:
    favorite_index = browser_model.findPath("favorites:")
    to_be_removed = []
    for i in range(browser_model.rowCount(favorite_index)):
        index = browser_model.index(i, 0, favorite_index)
        path = index.data()
        dirname = os.path.dirname(path)
        if base_directory == dirname or work_directory == path:
            to_be_removed.append(index)
    for remove_index in to_be_removed:
        browser_model.removeFavorite(remove_index)
except Exception as e:
    QgsMessageLog.logMessage(str(e))

# add the users pwd and work/home  as it will be hard for user to find it in the Browser
browser_model.addFavoriteDirectory(new_favorite_directory)
browser_model.addFavoriteDirectory(work_directory)
browser_model.addFavoriteDirectory(scratch_directory)