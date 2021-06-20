import { Elm } from './Main.elm';
import './Styles/index.scss';
import { Loader } from '@googlemaps/js-api-loader';



const API_KEY = "AIzaSyCLu9vknAfT0hurEMqWgNosoVzgsqbMyzg";

let map: any;
let google: any;

const app = Elm.Main.init({
    node: document.getElementById('app'),
    flags: API_KEY
});


async function loadGoogleMaps(): Promise<void> {
    const loader = new Loader({
      apiKey: API_KEY,
      version: "weekly",
      libraries: ["places"]
    });

    google = await loader.load();

    const berlin = { lat: 52.5145658, lng: 13.3907269 };
    map = new google.maps.Map(document.getElementById("map"), {
      center: berlin,
      zoom: 14,
    });

    //const request = {
    //location: berlin,
    //radius: '10000',
    //type: ['street']
    //};

    //const service = new google.maps.places.PlacesService(map);
    //service.nearbySearch(request, callback);

    //google.maps.event.addListenerOnce(map, 'idle', function(){
    //setMyLocation();
    app.ports.requestMarkers.send("");
    //});
}

//function callback(results, status) {
  //if (status == google.maps.places.PlacesServiceStatus.OK) {
      //console.log('results', results, status);
  //}
//}

//function setMyLocation() {
    //if (navigator.geolocation) {
        //navigator.geolocation.getCurrentPosition(
            //(position) => {
                //const pos = {
                    //lat: position.coords.latitude,
                    //lng: position.coords.longitude,
                //};
                //new google.maps.Marker({
                    //position: { lat: pos.lat, lng: pos.lng },
                    //map,
                    //icon: "http://maps.google.com/mapfiles/kml/paddle/grn-circle.png",
                    //title: "Your location",
                //});
            //},
            //() => {
                //// TODO error 
            //}
        //);
    //} else {
        //// Browser doesn't support Geolocation TODO
    //}
//}


app.ports.sendSearch.subscribe((search: string)  => {
  console.log('search', search);
});

app.ports.sendMaps.subscribe((message: any) => {
    if (message === "load") {
        loadGoogleMaps();
    } 
});

app.ports.sendMarkers.subscribe((markers: any) => {
    console.log('markers', markers);

    markers.forEach((markerItem: any) => {
        const marker = new google.maps.Marker({
            position: { lat: markerItem.lat, lng: markerItem.lng },
            map,
            title: markerItem.displayName,
        });

        marker.addListener("click", () => {
            console.log('marker clicked', marker);
        });
    });
});

