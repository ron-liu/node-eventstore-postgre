Promise = require 'bluebird'
pg = require 'pg'
fs = require 'fs'

Promise.promisifyAll pg.Client
Promise.promisifyAll pg.Connection
Promise.promisifyAll pg.Query
Promise.promisifyAll pg
Promise.promisifyAll fs

class eventStore
	constructor: (connStr, publish)->
		@connStr = connStr
		if not publish? || typeof publish isnt 'function' then throw new Error 'Please pass in publish function as 2nd param'
		@publish = publish

	init: =>
		fs.readFileAsync "#{__dirname}/init.sql"
		.then (data) -> data.toString()
		.then (sql) =>
			pg.connectAsync @connStr
			.spread (client, release) ->
				client.queryAsync sql
				.finally -> release()

	writeEvents: (aggregateId, aggregateType, originatingVersion, events) =>
		pg.connectAsync @connStr
		.spread (client, release) =>
			client.queryAsync 'select writeEvents($1::uuid, $2::varchar(256), $3::int, $4::json[])', [aggregateId, aggregateType, originatingVersion, events]
			.finally -> release()
		.then => Promise.all (@publish e for e in events)

	readEvents: (aggregateId) =>
		pg.connectAsync @connStr
		.spread (client, release) ->
			client.queryAsync 'select data from events where aggregateId = $1::uuid order by version;', [aggregateId]
			.finally -> release()
		.then (result) -> row.data for row in result.rows

module.exports = eventStore