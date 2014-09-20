create table if not exists aggregates (
	aggregateId uuid primary key,
	type varchar(256) not null,
	version int not null
);

create table if not exists events (
	aggregateId uuid not null references aggregates(aggregateId),
	data json not null,
	sequenceNumber bigserial,
	version int not null,
	createdOn timestamp with time zone default now()
);

create table if not exists snapshots (
	aggregateId uuid not null references aggregates(aggregateId),
	data json not null,
	version int not null
);

-- Make sure there is no same version event in one aggregate
DO $$
BEGIN
if not exists ( select * from pg_class c join pg_namespace n on n.oid=c.relnamespace where c.relname = 'ix_events_aggregateid_version' and n.nspname = 'public') THEN
	create unique index ix_events_aggregateid_version on events (aggregateId, version);
end if;
END$$;

create or replace function writeEvents(_aggregateId uuid, _aggregateType varchar(256), _originatingVersion int, _events json [], _aggregateSnapshot json) returns void as $$
declare
	currentVersion int;
	event json;
begin
	select version into currentVersion from aggregates where aggregateId = _aggregateId;
	if not found then
		insert into aggregates(aggregateId, type, version) values(_aggregateId, _aggregateType, 0);
		currentVersion := 0;
	end if;

	if _originatingVersion != currentVersion then
		raise 'Concurrency conflicts for versions, database version: %, passing version: %', currentVersion, _originatingVersion  using hint = 'Please try to write again.';
		rollback;
	end if;

	foreach event in array _events
	loop
		currentVersion := currentVersion + 1;
		insert into events(aggregateId, data, version) values(_aggregateId, event, currentVersion);
	end loop;
	update aggregates set version = currentVersion where aggregateId = _aggregateId;

	-- write to snapshots, upsert
	if not _aggregateSnapshot is null then
		update snapshots set data = _aggregateSnapshot, version = currentVersion where aggregateId = _aggregateId;
		insert into snapshots(aggregateId, data, version)
			select _aggregateId, _aggregateSnapshot, currentVersion
			where not exists (select 1 from snapshots where aggregateId = _aggregateId);
	end if;
end;
$$ language plpgsql;