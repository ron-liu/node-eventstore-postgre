EventStore = require('../eventStore')
pg = require 'pg'
uuid = require 'uuid'
expect = require('chai').expect
_ = require 'lodash'
Promise = require 'bluebird'

connStr = 'postgres://ronliu:123456@localhost/test'
describe 'load test', ->

	published = []
	publish = (e) -> published.push e
	eventStore = new EventStore connStr, publish

	before (done)-> eventStore.init().then done()

	it.only 'write 1000 events', (done) ->
		promises = _.map _.range(1000),->
			eventStore.writeEvents uuid.v4(), 'customer', 0, [
				{eventName: 'customerAdded', data: name: 'added', createdOn: new Date()},
				{eventName: 'customerActivated', data: name: 'added', createdOn: new Date()}
			]

		Promise.all promises
		.then ->
			expect(published.length).to.equal 2000
			done()
		.catch (err) -> done(err)
