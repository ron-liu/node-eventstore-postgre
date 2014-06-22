node-eventstore-postgre
=======================

## Why I create this eventstore?
I firstly checked [Grey Young's event store](http://www.geteventstore.com), but it only provide atom REST interface for node.js, 
which need too many round trips (each event for each round trip) to get events from a given aggregate.

Later I tried to find node.js event store implementations, however, many are using NOSQL databases which I don't think it will support 
transaction very well. 

Finally, I decide write a simple one using rational database. 

Inspired by [Grey Young's cqrs document](http://cqrs.files.wordpress.com/2010/11/cqrs_documents.pdf).

## Install
```
npm install node-eventstore-postgre
```

## APIs
I am using coffeescript to the usages. before everything, do this
``` coffeescript
EventStore = require 'node-eventstore-postgre'
eventStore = new EventStore 'postgres://ronliu:123456@localhost/test'   #Pass in postgre connection string
eventStore.init()   #Initialise necessary tables and functions using create if not exists style
```
### Get events from a given aggregate id
``` coffeescript
events = eventStore.readEvents aggregateId  #aggregateId is uuid
```
### Write events to 
it will take 4 arguments:

* aggregateId
* aggregate type
* originating version: the version when we read used to check optimistic concurrency conflicts
* events array

``` coffeescript
eventStore.writeEvents aggregateId, 'customer', 2, [
	{eventName: 'customerAdded', data: name: 'ron', createdOn: new Date()},
	{eventName: 'customerActivated', data: comment: 'good customer'},
]
```

## Status
It is in very early stage, and right now just finished two basic APIs. I will evolve this with my other projects which consume this one. 
