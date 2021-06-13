import Elm from './Main.elm';
import './Styles/index.scss';

let map;

const app = Elm.Main.init({
  node: document.getElementById('app')
});

const API_KEY = "AIzaSyCLu9vknAfT0hurEMqWgNosoVzgsqbMyzg";

function loadGoogleMaps() {
    window.initMap = () => {
        map = new google.maps.Map(document.getElementById("map"), {
            center: { lat: 52.5145658, lng: 13.3907269 },
            zoom: 14,
        });

        map.addListener('tilesloaded', () => {  
            app.ports.requestMarkers.send(API_KEY);
        });
    }

    const script = document.createElement("script");
    script.src = `https://maps.googleapis.com/maps/api/js?key=${API_KEY}&callback=window.initMap&libraries=&v=weekly`;
    document.body.append(script);
}

app.ports.sendMaps.subscribe(message =>  {
    if (message === "load") {
        loadGoogleMaps();
    }
});

app.ports.sendMarkers.subscribe(markers => {
    console.log('markers', markers);

    markers.forEach(markerItem => {
        new google.maps.Marker({
            position: { lat: markerItem.lat, lng: markerItem.lng },
            map,
            title: markerItem.displayName,
        });
    });
});
