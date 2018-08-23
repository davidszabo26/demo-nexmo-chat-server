# Virgil Nexmo Demo Chat API v2 Sample Backend

Application API server for the [Virgil Nexmo In-app Messaging Demo app](https://github.com/VirgilSecurity/demo-nexmo-chat-android). Its primary purpose is to register users' Virgil Cards on  Virgil's Cards service and generate JWTs for users to access Nexmo and Virgil APIs. This server 
is intended for demonstration purposes only, it does not implement request authentication strategy. Feel free to implement your own auth tech and/or copy the code into your own backend.

 ## Contents
 * [Deployment](#deployment)
    * [Pre-requisites](#pre-requisites)
    * [Setup instructions](#setup-instructions)
 * [Endpoints](#endpoints)
    * [POST /users](#post-users)
    * [GET /users](#get-users)
    * [POST /conversations](#post-conversations)
    * [PUT /conversations](#put-conversations)
    * [GET /nexmo-jwt](#get-nexmo-jwt)
    * [GET /virgil-jwt](#get-virgil-jwt)
 * [Errors](#errors)

## Deployment

### Pre-requisites

* Ensure you have [Node.js](https://nodejs.org/en/) >= 8 installed
* Create a free [Virgil Security](https://dashboard.virgilsecurity.com/) account
* Create a free [Nexmo](https://dashboard.nexmo.com/) account
* Install the Nexmo CLI (note the `@beta` tag):
	```sh
	npm install -g nexmo-cli@beta
	```
	Setup the CLI to use your Nexmo API Key and API Secret. You can get these from the 
	[settings](https://dashboard.nexmo.com/settings) page in the Nexmo Dashboard.
	```sh
	nexmo setup api_key api_secret
	```

### Setup instructions

* Create an **END-TO-END ENCRYPTION** Application in the Virgil Security [Dashboard](https://dashboard.virgilsecurity.com/apps/new)
* Create an **API Key** in the Virgil Security [Dashboard](https://dashboard.virgilsecurity.com/api-keys)
* Create a Nexmo Application
	```sh
	nexmo app:create "My Stitch App" https://example.com/answer https://example.com/event --type=rtc --keyfile=private.key
	```
* Run the `setup` npm script and follow the instructions to configure the server
	```sh
	npm run setup
	```
* Start the server
	```sh
	npm start
	```
* Run the tests to verify that it's working
	```sh
	npm test
	```
* You can access the server API at http://localhost:3000
 
 ## Endpoints
 
 ### POST /users
 
 An endpoint to register new user. Expects a _Raw Card_ in base64 string form as its only parameter.
 The raw card must have unique identity, attempt to register a card with duplicate identity will result in
 `400 BadRequest` error.
 
 **Request**
 ```json
{
	"raw_card_string": "eyJjb250ZW50X3NuYXBzaG90IjoiZXlKcFpHVnVkR2...k9In19fQ=="
}
```

**Response**

If request is successful, an object representing a [Nexmo user](https://developer.nexmo.com/stitch/in-app-messaging/guides/simple-conversation)
is returned along with the base64 string representation of the user's Virgil Card and two JWTs for Nexmo and Virgil
APIs:

> Request must include `Content-Type: "application/json"` header 
 
```json
{
	"user": {
		"id": "USR-aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
		"href": "http://conversation.local/v1/users/USR-aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
		"virgil_card": "eyJjb250ZW50X3NuYXBzaG90IjoiZXlKcFpHVnVkR2...k9In19fQ=="
	},
	"nexmo_jwt": "xxxxx.yyyyy.zzzzz",
	"virgil_jwt": "qqqqq.bbbbb.ddddd"
}
```
You can then use the `CardManager` from virgil sdk to `import` a Virgil Card from this string. The `nexmo_jwt` and
 `virgil_jwt` can be used to initialize the appropriate API client.

### GET /users

An endpoint to retrieve a list of users.

**Response**

```json
[
	{
		"name": "Dillon",
		"id": "USR-aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
		"href": "http://conversation.local/v1/users/USR-aaaaaaaa-bbbb-cccc-dddd-0123456789ab"
	}
]
```

### POST /conversations

An endpoint to create a new [Nexmo Conversation](https://developer.nexmo.com/stitch/in-app-messaging/guides/simple-conversation)

**Request**

```json
{
	"display_name": "My new conversation" 
}
```

**Response**

```json
{
	"id": "CON-aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
	"href": "http://conversation.local/v1/conversations/CON-aaaaaaaa-bbbb-cccc-dddd-0123456789ab"
}
```
   
### PUT /conversations

An endpoint to add a user to a conversation.

**Request**

```json
{
	"conversation_id": "CON-aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
	"user_id": "USR-aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
	"action": "join"
}
```

Parameter action must be "join" to add the user to the conversation. Other types of actions - TBD.

**Response**

```json
{ 
	"id": "MEM-aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
	"user_id": "USR-aaaaaaaa-bbbb-cccc-dddd-0123456789ab",
	"state": "JOINED",
	"timestamp": { "joined": "2018-01-15T15:17:59.248Z" },
	"channel": { "type": "app" },
	"href": "http://conversation.local/v1/conversations/CON-aaaaaaaa-bbbb-cccc-dddd-0123456789ab/members/MEM-aaaaaaaa-bbbb-cccc-dddd-0123456789ab"
}
```

### GET /nexmo-jwt?identity=[YOUR_USER_IDENTITY]

An endpoint to obtain an access token for the Nexmo API. The URL must include a query parameter named `identity` that is the identity of the user to issue the token for.

**Response**
```json
{
	"jwt": "xxxxx.yyyyy.zzzzz"
}
```

### GET /virgil-jwt

An endpoint to obtain an access token for the Virgil Security API. The URL must include a query parameter named `identity` that is the identity of the user to issue the token for.

**Response**
```json
{
	"jwt": "qqqqq.bbbbb.ddddd"
}
```

## Errors

Application uses standard HTTP response codes:

```
200 - Success
400 - Request error
500 - Server error
```

Additional information about the error is returned in response body as JSON object:
```json
{
	"status": 500,
	"error_code": 50000,
	"message": "Message containing error details"
}
```
