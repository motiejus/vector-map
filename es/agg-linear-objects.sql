/* Aggregates streets or rivers by name and proximity. */
drop function if exists agg_linear_objects;
create or replace function agg_linear_objects(p_type text) returns table(osm_id bigint, name text, way geometry) as $$
declare
  c record;
  cc record;
  ccc record;
begin
  create temporary table agg_tmp_objects (osm_id bigint, name text, way geometry);
  create index agg_tmp_objects_id on agg_tmp_objects(osm_id);
  create index agg_tmp_objects_gix on agg_tmp_objects using gist(way);

  create temporary table bfs_queue (osm_id bigint, way geometry);
  create index bfs_queue_id on bfs_queue(osm_id);

  if p_type = 'r' then
    insert into agg_tmp_objects
      select p.osm_id, p.name, p.way from planet_osm_line p
        where waterway in ('river', 'stream', 'canal') and p.name is not null;
  elsif p_type = 's' then
    insert into agg_tmp_objects
      select p.osm_id, p.name, p.way from planet_osm_line p
        where highway in ('motorway', 'trunk', 'primary', 'secondary', 'tertiary',
          'unclassified', 'residential', 'track', 'living_street') and p.name is not null;
  else
    raise 'p_type can only be "r" or "s"';
  end if;

  while (select count(1) from agg_tmp_objects) > 0 loop
    select * from agg_tmp_objects limit 1 into c;
    insert into bfs_queue (osm_id, way) values (c.osm_id, c.way);
    delete from agg_tmp_objects a where a.osm_id = c.osm_id;
    while (select count(1) from bfs_queue) > 0 loop
      select * from bfs_queue limit 1 into cc;
      delete from bfs_queue where bfs_queue.osm_id = cc.osm_id;
      for ccc in (select a.osm_id, a.way from agg_tmp_objects a where a.name = c.name and st_dwithin(a.way, cc.way, 500)) loop
        insert into bfs_queue (osm_id, way) values(ccc.osm_id, ccc.way);
        delete from agg_tmp_objects a where a.osm_id = ccc.osm_id;
        c.way = st_linemerge(st_union(c.way, ccc.way));
      end loop; -- for ccc in (...)
    end loop; -- while len(bfs_queue) > 0
    insert into agg_objects (object_type, osm_id, name, way) values (p_type, c.osm_id, c.name, c.way);
  end loop; -- while len(agg_tmp_objects) > 0

  drop table agg_tmp_objects;
  drop table bfs_queue;
end
$$ language plpgsql;

drop table if exists agg_objects;
create table agg_objects (id serial primary key, object_type text, osm_id bigint, name text, way geometry);
select agg_linear_objects('r');
select agg_linear_objects('s');
