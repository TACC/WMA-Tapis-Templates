from qgis.core import QgsExpressionContextUtils
from qgis.utils import iface


def customize():
    version = QgsExpressionContextUtils.globalScope().variable('qgis_version')
    title = iface.mainWindow().windowTitle()
    iface.mainWindow().setWindowTitle('{} | {}'.format(title, version))

iface.initializationCompleted.connect(customize)