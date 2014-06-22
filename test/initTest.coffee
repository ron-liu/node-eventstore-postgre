EventStore = require('../eventStore')
pg = require 'pg'
connStr = 'postgres://ronliu:123456@localhost/test'

describe 'init', ->
	eventStore = null

	before (done)->
		eventStore = new EventStore connStr
		pg.connectAsync connStr
		.spread (client, release) ->
			client.queryAsync 'drop table if exists events'
			.then ->client.queryAsync 'drop table if exists aggregates'
			.then -> done()
			.catch (err)-> done err.message
			.finally -> release()

	it 'should init all tables', (done) ->
		eventStore.init()
		.then -> pg.connectAsync connStr
		.spread (client, release) ->
			client.queryAsync 'select 1 from events order by sequenceNumber limit 1'
			.then -> client.queryAsync 'select 1 from aggregates order by version limit 1'
			.then -> done()
			.catch (err)-> done err.message
			.finally -> release()
		.catch (err) -> done err.message

	it 'should allow init second time', (done) ->
		eventStore.init()
		.then -> done()
		.catch (err) -> done err.message

