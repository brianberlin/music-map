#!/bin/sh

bash /gisdata/nation.sh
psql -U postgres -d geocoder -o /gisdata/LA.sh -A -t -c "SELECT loader_generate_script(ARRAY['LA'], 'geocoder') AS result;"
chmod +x /gisdata/LA.sh
bash /gisdata/LA.sh
psql -U postgres -d geocoder -c "SELECT install_missing_indexes();"
touch /tmp/ready
