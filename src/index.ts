import { Elm } from './Main.elm';
import './Styles/index.scss';
import { Loader } from '@googlemaps/js-api-loader';

interface Location {
  lat: number;
  lng: number;
}

interface MarkerData extends Location {
  streetName: string;
  number: String;
  postalCode: String;
  city: String;
  displayName: String;
}

const API_KEY = "AIzaSyCLu9vknAfT0hurEMqWgNosoVzgsqbMyzg";
const berlin = { lat: 52.5145658, lng: 13.3907269 };

let input: HTMLInputElement;
let map: google.maps.Map;
let google: typeof globalThis.google;
let autocomplete: google.maps.places.Autocomplete;
let markers: google.maps.Marker[] = [];

const app = Elm.Main.init({
    node: document.getElementById('app'),
});

async function loadGoogleMaps(): Promise<void> {
    const loader = new Loader({
      apiKey: API_KEY,
      version: "weekly",
      libraries: ["places"]
    });

    google = await loader.load();

    map = new google.maps.Map(document.getElementById("map"), {
      center: berlin,
      zoom: 14,
    });


    setMyLocation();
    input = document.querySelector("#search-input") as HTMLInputElement;

    autocomplete = new google.maps.places.Autocomplete(input, {
      componentRestrictions: { country: ["de", "be"] },
      fields: ["address_components", "geometry"],
      types: ["address"],
    });

    google.maps.event.addListener(autocomplete, 'place_changed', () => {
      const place = autocomplete.getPlace();
      const placeLocation = place.geometry.location;

      const location = {
        lat: placeLocation.lat(),
        lng: placeLocation.lng()
      }

      app.ports.requestNearestMarker.send(location);
    });

    app.ports.requestMarkers.send("");
}

function setMyLocation() {
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(
            (currentPosition) => {
                const position = {
                    lat: currentPosition.coords.latitude,
                    lng: currentPosition.coords.longitude,
                };
                new google.maps.Marker({
                    position,
                    map,
                    icon: "http://maps.google.com/mapfiles/kml/paddle/grn-circle.png",
                    title: "Your location",
                });
            },
            () => {
            }
        );
    } else {
        // Browser doesn't support Geolocation TODO
    }
}

function removeMarkers() {
    markers.forEach(marker => {
      marker.setMap(null);
    });

    markers = [];
}

app.ports.toJSLoadMaps.subscribe((message: any) => {
  loadGoogleMaps();
});

app.ports.toJSMarkers.subscribe((items: MarkerData[]) => {
    removeMarkers();

    items.forEach((markerItem: any) => {
        const marker = new google.maps.Marker({
            position: { lat: markerItem.lat, lng: markerItem.lng },
            map,
            title: markerItem.displayName,
        });

        marker.addListener("click", () => {
            const location: Location = {
              lat: marker.getPosition().lat(),
              lng: marker.getPosition().lng()
            }

            app.ports.toElmMarkerSelected.send(location);
        });

        markers.push(marker);

    });
});

