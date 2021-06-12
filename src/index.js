import Elm from './Main.elm';
import './Styles/index.scss';

let map;

const app = Elm.Main.init({
  node: document.getElementById('app')
});

function loadGoogleMaps() {
    window.initMap = () => {
        map = new google.maps.Map(document.getElementById("map"), {
            center: { lat: 52.5086018, lng: 13.3273299 },
            zoom: 12,
        });

        const listener = map.addListener('tilesloaded', () => {  
            // port 
            app.ports.requestMarkers.send("");
        });
        listener.d
    }

    const script = document.createElement("script");
    script.src = "https://maps.googleapis.com/maps/api/js?key=AIzaSyBQ9fR6ZPQePTzI0ZDyIbaR_eZ18f_NA9Y&callback=window.initMap&libraries=&v=weekly";
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
        const marker  = new google.maps.Marker({
            position: { lat: markerItem.lat, lng: markerItem.lng },
            map,
            title: markerItem.displayName,
        });

        //marker.addListener("click", () => toggleBounce(marker));
    });
});
