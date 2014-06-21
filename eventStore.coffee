Promise = require 'bluebird'
pg = require 'pg'
uuid = require 'uuid'
fs = require 'fs'

#Promise.promisifyAll pg.Client.prototype
Promise.promisifyAll pg.Client
#Promise.promisifyAll pg.Connection.prototype
Promise.promisifyAll pg.Connection
#Promise.promisifyAll pg.Query.prototype
Promise.promisifyAll pg.Query
Promise.promisifyAll pg
Promise.promisifyAll fs

Promise.promisifyAll(fs)

class eventStore
	constructor: (connStr)-> @connStr = connStr

	init: =>
		fs.readFileAsync "#{__dirname}/init.sql"
		.then (data) -> data.toString()
		.then (sql) =>
			pg.connectAsync @connStr
			.spread (client, release) -> client.queryAsync sql

module.exports = eventStore