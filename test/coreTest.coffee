EventStore = require('../eventStore')
pg = require 'pg'
uuid = require 'uuid'
expect = require('chai').expect

connStr = 'postgres://ronliu:123456@localhost/test'

describe 'write/read events', ->
	eventStore = new EventStore connStr
	aggregateId = uuid.v4()

	before (done)-> eventStore.init().then done()

	it.only 'read after writing should work', (done) ->
		eventStore.writeEvents aggregateId, 'customer', 0, [
			{eventName: 'customerAdded', data: name: 'added', createdOn: new Date()},
			{eventName: 'customerActivated', data: name: 'added', createdOn: new Date()}
		]
		.then -> eventStore.readEvents aggregateId
		.then (events) ->
			console.log events.rows
			expect(events.length).to.equal 2
		.then -> done()
		.catch (err) -> done(err.message)
