# Dependencies

## Nominatim

```
docker create volume nominatim;

docker run -d -p 8080:8080 \
-e NOMINATIM_PBF_URL='http://download.geofabrik.de/north-america/us/louisiana-latest.osm.pbf' \
--name nominatim peterevans/nominatim:latest \
--mount source=nominatim,target=/srv/nominatim/data
```

## Tile Server

```
docker run --rm -d -v (pwd)/map_tiles:/data -p 8181:80 maptiler/tileserver-gl
```