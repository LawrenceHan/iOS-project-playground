# Architecture

Originally copied from: 20140801_Carevoice_documentation.pdf

## Data Modeling

Relationship Cardinality

* USER has many MEDICAL EXPERIENCES
* MEDICAL EXPERIENCE has one or no HOSPITAL REVIEW
* MEDICAL EXPERIENCE has many or no PHYSICIAN REVIEWS
* MEDICAL EXPERIENCE has many or no MEDICATION REVIEWS

Note: see http://en.wikipedia.org/wiki/Cardinality_(data_modeling) for more details 
on cardinality and see https://github.com/thecarevoice/docs

## API Authorized Guidelines 

### Resource oriented

So that it's the same thing as we organize the logic in the server code.
Always try to expose a service as a resource, instead of an action.
e.g. Create an item in the shopping cart rather than Add this item to the shopping cart

### Top level resources 

Resources should be top level, whenever it's not dependent on others e.g. /session rather than /account/sessions.
A user is expected to have only one session. And the session, is not dependent upon another resource.

### HTTP response code 

Conform to HTTP 1.1 specification as much as possbible. For all the resource
oriented API endpoints, usually the status code itself is enough for the
reason of an error.

### Response body - no wrapper 

Preferred format:

Successful response :

```
// GET /users/1234
{
  "name": "Alice",
  "email": "alice@kangyu.co"
}
```

Error response 

```
// GET /profile
// status: 401 # - Good enough for the client app  to know the reason of the failure
{
  errors: ['You have to login to proceed'] // The message that can be displayed to the user.
}
```

### Hypermedia driven

Hypermedia is said to be the core of the entire RESTful, but very hard to achieve
in the API design. However even mixing some of the hypermedia, can greatly improve
the flexibility and maintainability of the API -
it moves logic from the client to the server.


### Client should never have to construct a URI
 
Though URIs like /users/1234 is well known and easy to construct, they can be
eliminated from the client site. For most of the cases a user detail page,
is discovered from a users collection page. Thus in the users' collection page,
you should pass the URI for each user along with their ids. 


```
// GET /users
[
  {
    "id":"1",
    "uri": "/users/1",
    "name": "Alice",
    "email": "alice@kangyu.co",
  },
  {
    "id":"2",
    "uri": "/users/2",
    "name": "Bob",
    "email": "bob@kangyu.co"
  }
]
```

### RPC when necessary

Fully resourceful can be achieved, but sometimes it can be very hard or awkward.
Example would be that move the resource to another place sounds better and
natural than create a copy of this resource in that place,
 and delete this from here, aka, the transactional ones.

 For all RPC calls, it should be POST /<resource name>/<id>/<action_name>

 e.g.

 ```
 POST /letters/1234/move_to_fridge
 ```
 Additionally, the action that can be done to a resource,
 should be included in the detailed representation of that resource,
 inside a dictionary called '_actions'

 e.g.

 ```
 {
    "id": "1234",
    "title": "letter title",
    "_actions": {
      "move_to_fridge": "https://lettrs.com/letters/1234/move_to_fridge"
    }
 }
 ```

 In this way, the client can know whether an action is available to a resource. 
