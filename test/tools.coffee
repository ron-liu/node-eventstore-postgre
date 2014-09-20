bluebird = require 'bluebird'
pg = require 'pg'

bluebird.promisifyAll(pg.Client);
bluebird.promisifyAll(pg.Connection);
bluebird.promisifyAll(pg.Query);
bluebird.promisifyAll(pg);

connString = 'postgres://ronliu:123456@localhost/test'

exports.connString = connString
exports.cleanUp =  =>
	pg.connectAsync connString
	.spread (client, release) =>
		client.queryAsync 'truncate aggregates cascade;'
		.then -> client.queryAsync 'drop table if exists events; drop table if exists snapshots; drop table if exists aggregates;'
		.finally -> release()