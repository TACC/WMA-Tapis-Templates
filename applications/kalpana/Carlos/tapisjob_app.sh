set -xe
#loading required modules
module load python3

#installing lib
pip3 install --user --upgrade pip
pip3 install --user shapely
pip3 install --user fiona
pip3 install --user simplekml
pip3 install --user netCDF4
echo "Successfully installed libraries"

#path where the python script lives
git clone https://github.com/TACC/Kalpana.git

sleep 5

pwd
mv ${filetype} output/

cd output/

#read from tapisjob.env file and grab range to format
range_value=$(grep 'range=' ../tapisjob.env | cut -d'=' -f2)
echo "Extracted range: ${range_value}"

#execute python script
python3 ../Kalpana/Kalpana_N.py --storm test --filetype ${filetype} --polytype ${polytype} --viztype shapefile --subplots no --${contour} "${range_value}"

rm -rf ../Kalpana
