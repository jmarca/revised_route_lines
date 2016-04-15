# SQL to help smooth out OSM irritants

I'm not trying to fix OSM, so much as make it easier for me to use for
my purpose.


# Result

``` SQL
osm=# select geometrytype(linestring),count(*) from tempseg.initial_routelines group by geometrytype(linestring);
  geometrytype   | count
-----------------+-------
 LINESTRING      |   320
 MULTILINESTRING |   338
(2 rows)
```

And after:

```
osm=# select geometrytype(routeline),count(*) from tempseg.revised_route_lines group by geometrytype(routeline);
  geometrytype   | count
-----------------+-------
 LINESTRING      |   361
 MULTILINESTRING |   294
(2 rows)
```

So not much help, but whatever.  40 odd lines fixed, I guess
