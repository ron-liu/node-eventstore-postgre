node-eventstore-postgre
=======================

## Why I create this eventstore?
I firstly checked [Greg Young's event store](http://www.geteventstore.com), but it only provide atom REST interface for node.js, 
which need too many round trips (each event for each round trip) to get events from a given aggregate.

Later I tried to find node.js event store implementations, however, many are using NOSQL databases which I don't think it will support 
transaction very well. 

Finally, I decide write a simple one using rational database. 

Inspired by [Greg Young's cqrs document](http://cqrs.files.wordpress.com/2010/11/cqrs_documents.pdf).

## Install
```
npm install node-eventstore-postgre
```

## APIs
I am using coffeescript to the usages. before everything, do this
``` coffeescript
EventStore = require 'node-eventstore-postgre'
eventStore = new EventStore 'postgres://ronliu:123456@localhost/test', publish   #Pass in postgre connection string and publish method
eventStore.init()   #Initialise necessary tables and functions using create if not exists style
```
### Get events from a given aggregate id
It will take 2 arguments:

* aggregateId
* startOverVersion, like given 3, it should return events from version 4
 
``` coffeescript
events = eventStore.readEvents aggregateId, statOverVersion
```

### Given aggregate id, output a snap shot with version

It will take 2 arguments:
 
* aggregateId
``` coffeescript
snapshot = eventStore.readSnapshot aggregateId # {data: aggregate, version: version} or undefined
```

### Write events to 
It will take 4 arguments:

* aggregateId
* aggregate type
* originating version: the version when we read used to check optimistic concurrency conflicts
* events array
* snapshot

``` coffeescript
eventStore.writeEvents aggregateId, 'customer', 2, [
	{eventName: 'customerAdded', data: name: 'ron', createdOn: new Date()},
	{eventName: 'customerActivated', data: comment: 'good customer'},
], name: 'john', isActive: true
```

## Status
* From 0.2, it support snapshot 
