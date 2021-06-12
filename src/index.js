import Elm from './Main.elm';
import './Styles/index.scss';


const app = Elm.Main.init({
  node: document.getElementById('app')
});

// TODO use elm port 
const markers = (map) => {

    const marker  = new google.maps.Marker({
        position: { lat: 52.5086018, lng: 13.3273299 },
        map,
        animation: google.maps.Animation.DROP,
        title: "Hello World!",
    });

    marker.addListener("click", () => toggleBounce(marker));
}

function toggleBounce(marker) {
  if (marker.getAnimation() !== null) {
    marker.setAnimation(null);
  } else {
    marker.setAnimation(google.maps.Animation.BOUNCE);
  }
}

function loadGoogleMaps() {
    window.initMap = () => {
        const map = new google.maps.Map(document.getElementById("map"), {
            center: { lat: 52.5086018, lng: 13.3273299 },
            zoom: 12,
        });

        // Port message fetch request
        app.ports.fetchMarkers.send();
        markers(map);
    }

    const script = document.createElement("script");
    script.src = "https://maps.googleapis.com/maps/api/js?key=AIzaSyBQ9fR6ZPQePTzI0ZDyIbaR_eZ18f_NA9Y&callback=window.initMap&libraries=&v=weekly";
    document.body.append(script);
    setTimeout(() => console.log('map', map), 1000);
}

// When a command goes to the `sendMessage` port, we pass the message
// along to the WebSocket.
app.ports.mapsSend.subscribe(message =>  {
    if (message === "load") {
        loadGoogleMaps();
    }
});

