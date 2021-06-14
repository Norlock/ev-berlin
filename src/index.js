import Elm from './Main.elm';
import './Styles/index.scss';

const API_KEY = "AIzaSyCLu9vknAfT0hurEMqWgNosoVzgsqbMyzg";

let map;

const app = Elm.Main.init({
    node: document.getElementById('app'),
    flags: API_KEY
});


function loadGoogleMaps() {
    window.initMap = () => {
        map = new google.maps.Map(document.getElementById("map"), {
            center: { lat: 52.5145658, lng: 13.3907269 },
            zoom: 14,
        });

        google.maps.event.addListenerOnce(map, 'idle', function(){
            setMyLocation();
            app.ports.requestMarkers.send("");
        });
    }

    const script = document.createElement("script");
    script.src = `https://maps.googleapis.com/maps/api/js?key=${API_KEY}&callback=window.initMap&libraries=&v=weekly`;
    document.body.append(script);
}

function setMyLocation() {
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
            (position) => {
                const pos = {
                    lat: position.coords.latitude,
                    lng: position.coords.longitude,
                };
                new google.maps.Marker({
                    position: { lat: pos.lat, lng: pos.lng },
                    map,
                    icon: "http://maps.google.com/mapfiles/kml/paddle/grn-circle.png",
                    title: "Your location",
                });
            },
            () => {
                // TODO error 
            }
        );
    } else {
        // Browser doesn't support Geolocation TODO
    }
}

app.ports.sendMaps.subscribe(message =>  {
    if (message === "load") {
        loadGoogleMaps();
    }
});

app.ports.sendMarkers.subscribe(markers => {
    console.log('markers', markers);

    markers.forEach(markerItem => {
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
