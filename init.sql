create table if not exists events (
	aggregateId uuid not null,
	eventName varchar(128) not null,
	data json not null,
	sequenceNumber bigserial,
	version int not null
);