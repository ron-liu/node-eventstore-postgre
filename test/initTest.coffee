EventStore = require('../eventStore')
pg = require 'pg'
tools = require './tools'

describe 'init', ->
	eventStore = new EventStore tools.connString, ->

	beforeEach (done)->
		tools.cleanUp()
		.then -> done()

	it 'should init all tables', (done) ->
		eventStore.init()
		.then -> pg.connectAsync tools.connString
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

