EventStore = require('../eventStore')
pg = require 'pg'

connStr = 'postgres://ronliu:123456@localhost/test'

describe 'init', ->
	eventStore = null

	before -> eventStore = new EventStore connStr

	it 'should init all tables', (done) ->
		eventStore.init()
		.then ->
			pg.connectAsync connStr
			.spread (client, release) ->
				client.queryAsync 'select * from events'
				.then -> done()
				.catch (err)-> done err.message

	it 'should allow init second time', (done) ->
		eventStore.init()
		.then -> done()
		.catch (err) -> done err.message


