# Ev - berlin

This app exist of two parts, the Elm side and Typescript side. 

It will retrieve ev-chargers form a JSON file and display it on a screen. Retrieving this data is done 
through the Elm part, everything related with maps is done throught the Typescript part. It uses ports to transmit the data (markers/favorites).

* Dev server is Snowpack
* Styling is done with sass,
* Typescript is used as well for stricter typing outside of the Elm part.
* Uses local storage to save the favorites
* Uses autocomplete API to suggest the possible addresses

## To run
```sh
npm i
npm start
```

## To run the tests
```sh
npm test
```

