import { LightningElement, track } from 'lwc';
import getWeatherDetails from '@salesforce/apex/WeatherdetailsClass.getWeatherDetails';

export default class WeatherApiDetails extends LightningElement {
    city = '';
    @track weatherDetails = {};
    showWeatherDetails = false;
    errorMessage = '';

    handleInputChange(event) {
        this.city = event.target.value.trim();
        console.log(this.city);
        this.errorMessage = '';
        this.showWeatherDetails = false; // Hide details when the input changes
    }

    handleWeatherDetails() {
        console.log('button clicked'+ this.city);
        if (this.city) {
            getWeatherDetails({ cityName: this.city })
                .then((result) => {
                    if (result) {
                        console.log(result);
                        this.weatherDetails = result;
                        this.showWeatherDetails = true;
                        this.errorMessage = '';
                    } else {
                        this.showWeatherDetails = false;
                        this.errorMessage = 'No weather details found for this city.';
                    }
                })
                .catch((error) => {
                    this.showWeatherDetails = false;
                    this.errorMessage = 'Error retrieving weather details: ' + (error.body ? error.body.message : error.message);
                });
        } else {
            this.errorMessage = 'Please enter a city name.';
            this.showWeatherDetails = false;
        }
    }
}
