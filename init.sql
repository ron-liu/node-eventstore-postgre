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

create or replace function writeEvents(_aggregateId uuid, _aggregateType varchar(256), _originatingVersion int, _events json []) returns void as $$
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
		raise 'Concurrency conflicts for version' using hint = 'Please try to write again.';
		rollback;
	end if;

	foreach event in array _events
	loop
		currentVersion := currentVersion + 1;
		insert into events(aggregateId, data, version) values(_aggregateId, event, currentVersion);
	end loop;
	update aggregates set version = currentVersion where aggregateId = _aggregateId;
end;
$$ language plpgsql;