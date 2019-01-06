# Kong Service Virtualization
## Overview
This plugin will enable mocking virtual API request and response pairs through Kong Gateway.

## Explanation:

kong-service-virtualization schema 'virtual_tests' args: 
```
[
     {
           "name": "TestCase1",           
           "requestHttpMethod": "POST",
           "requestHash": "0296217561490155228da9c17fc555cf9db82d159732f3206638c25f04a285c4",
           "responseHttpStatus": "200",
           "responseContentType": "application/json",
           "response": "eyJtZXNzYWdlIjogIkEgQmlnIFN1Y2Nlc3MhIn0="
    },
    {         
           "name": "TestCase2",           
           "requestHttpMethod": "GET",
           "requestHash": "e2c319e4ef41706e2c0c1b266c62cad607a014c59597ba662bef6d10a0b64a32",
           "responseHttpStatus": "200",
           "responseContentType": "application/json",
           "response": "eyJtZXNzYWdlIjogIkFub3RoZXIgU3VjY2VzcyEifQ=="
    } 
]
```

Where TestCase1 and TestCase2 are the names of the virtual test cases and must be passed in as a header value:

X-VirtualRequest: TestCase1

or

X-VirtualRequest: TestCase2

The 'requestHash' arg is a Sha256(HTTP Request as query parameters or HTTP Body)
The 'response' arg is a Base64 encoded format of the response HTTP Body.

So the above plugin equates to these sudo requests:

```
https://gateway.company.com/virtualtest

POST:
{
   "virtual": "test"
}
Response : {"message": "A Big Success!"} as base64 encoded in plugin

GET:
hello=world&service=virtualized
Response : {"message": "Another Success!"} as base4 encoded in plugin

```

In the event you do not successfully match on request you will recieve a Sha256 comparison for you own personal debugging:
```
Status Code: 404 Not Found
Content-Length: 207
Content-Type: application/json; charset=utf-8

{"message":"No virtual request match found, your request yeilded: 46c4b4caf0cc3a5a589cbc4e0f3cd0492985d5b889f19ebc11e5a5bd6454d20f expected 0296217561490155228da9c17fc555cf9db82d159732f3206638c25f04a285c4"}
```

If the test case specificed in the header does not match anything found stored within the plugin your error would be like so:
Passing X-VirtualRequest: TestCase3 in header yeilds
```
Status Code: 404 Not Found
Content-Length: 49
Content-Type: application/json; charset=utf-8

{"message":"No matching virtual request found!"}
```

## Supported Kong Releases
Kong >= 1.0

## Installation
Recommended:
```
$ luarocks install kong-service-virtualization
```

Optional
```
$ git clone https://github.com/Optum/kong-service-virtualization
$ cd /path/to/kong/plugins/kong-service-virtualization
$ luarocks make *.rockspec
```

## Maintainers
[jeremyjpj0916](https://github.com/jeremyjpj0916)  
[rsbrisci](https://github.com/rsbrisci)  

Feel free to open issues, or refer to our Contribution Guidelines if you have any questions.
