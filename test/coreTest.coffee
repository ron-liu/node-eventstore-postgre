EventStore = require('../eventStore')
pg = require 'pg'
uuid = require 'uuid'
expect = require('chai').expect

connStr = 'postgres://ronliu:123456@localhost/test'

describe 'write/read events', ->

	published = []
	publish = (e) -> published.push e
	eventStore = new EventStore connStr, publish
	aggregateId = uuid.v4()

	before (done)-> eventStore.init().then done()

	it.only 'read after writing should work', (done) ->
		eventStore.writeEvents aggregateId, 'customer', 0, [
			{eventName: 'customerAdded', data: name: 'added', createdOn: new Date()},
			{eventName: 'customerActivated', data: name: 'added', createdOn: new Date()}
		]
		.then -> eventStore.readEvents aggregateId
		.then (events) ->
			expect(events.length).to.equal 2
			expect(events[0].eventName).to.not.be.undefined

		.then -> expect(published.length).to.equal 2
		.then -> eventStore.writeEvents aggregateId, 'customer', 2, [
			{eventName: 'customerAdded', data: name: 'added', createdOn: new Date()},
			{eventName: 'customerActivated', data: name: 'added', createdOn: new Date()}
		]
		.then -> eventStore.readEvents aggregateId
		.then (events) -> expect(events.length).to.equal 4
		.then -> expect(published.length).to.equal 4
		.then -> done()
		.catch (err) -> done(err.message)
