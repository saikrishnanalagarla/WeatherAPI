public with sharing class WeatherdetailsClass {
    
    @AuraEnabled
    public static WeatherdetailsWrapper  gettingWeatherDetails(String cityName){
        try {
            //build end point 
            //Note use Named credentials or Remote site settings
            String apiKey ='a13933ff48eb062e5ea4e37dfb7f0dac';
            String endPoint = 'http://api.openweathermap.org/data/2.5/weather';
            endPoint +='?q='+cityName;
            endPoint +='&units=metric';
            endPoint +='&APPID='+apiKey;
            System.debug(endPoint);

            HTTP htp = new HTTP();
            HttpRequest rqst = new HttpRequest();
            rqst.setEndpoint(endPoint);
            rqst.setMethod('GET');
            System.debug('request ==>'+rqst);

            HttpResponse response = htp.send(rqst);
            System.debug(JSON.deserializeUntyped(response.getBody()));

            WeatherdetailsWrapper weatherdetails = new WeatherdetailsWrapper();
            if (response.getStatusCode()== 200){
             Map<String,Object> result= (Map<String , Object>)JSON.deserializeUntyped(response.getBody());
             weatherdetails.cityName = String.valueOf(result.get('name'));
             Map<String,Object> mainResult = (Map<String,Object>)(result.get('main'));
             weatherdetails.humidity = String.valueOf(mainResult.get('humidity'));
             weatherdetails.temprature = String.valueOf(mainResult.get('temp'));
             weatherdetails.temp_min = String.valueOf(mainResult.get('temp_min'));
             weatherdetails.temp_max = String.valueOf(mainResult.get('temp_max'));
             weatherdetails.pressure = String.valueOf(mainResult.get('pressure'));
             weatherdetails.feels_like = String.valueOf(mainResult.get('feels_like'));
            }
            System.debug('Weather Wrapper class '+weatherdetails);
            return weatherdetails;
        } catch (Exception e) {
            System.debug(e.getMessage());
            return null;
        }
    }
    public class WeatherdetailsWrapper{
        @AuraEnabled public string cityName {get;set;}
        @AuraEnabled public string temprature {get;set;}
        @AuraEnabled public string pressure {get;set;}
        @AuraEnabled public string humidity {get;set;}
        @AuraEnabled public string feels_like {get;set;}
        @AuraEnabled public string temp_min {get;set;}
        @AuraEnabled public string temp_max {get;set;}
    }

    @AuraEnabled
    public static WeatherDetails getWeatherDetails(String cityName) {
        try {
            // Validate input
            if (String.isBlank(cityName)) {
                throw new AuraHandledException('City name cannot be empty.');
            }

            // Create the HTTP request
            HttpRequest request = new HttpRequest();

            String endPoint = 'callout:WeatherNC/current.json?q='+cityName;
            request.setEndpoint(endPoint);
            request.setMethod('GET');
            System.debug('Request Endpoint: ' + endPoint);

            // Send the request
            Http http = new Http();
            HttpResponse response = http.send(request);
            System.debug('Response Body: ' + response.getBody());

            // Parse and process the response
            if (response.getStatusCode() == 200) {
                WeatherDetails weatherDetails = parseWeatherResponse(response.getBody());
                System.debug('Parsed Weather Details: ' + weatherDetails);
                return weatherDetails;
            } else {
                throw new AuraHandledException('Please enter correct city name');
            }
        } catch (AuraHandledException e) {
            throw e; // Rethrow known exceptions
        } catch (Exception e) {
            //throw new AuraHandledException('An unexpected error occurred: ' + e.getMessage());
            throw new AuraHandledException('Please enter correct city name');
        }
    }

    // Helper method to parse the JSON response into a WeatherDetails object
    private static WeatherDetails parseWeatherResponse(String responseBody) {
        Map<String, Object> responseData = (Map<String, Object>) JSON.deserializeUntyped(responseBody);

        WeatherDetails weatherDetails = new WeatherDetails();
        
        // Extract location details
        Map<String, Object> locationDetails = (Map<String, Object>) responseData.get('location');
        weatherDetails.cityName = (String) locationDetails.get('name');
        weatherDetails.localTime = (String) locationDetails.get('localtime');

        // Extract current weather details
        Map<String, Object> currentDetails = (Map<String, Object>) responseData.get('current');
        weatherDetails.temperature = String.valueOf(currentDetails.get('temp_c'));
        weatherDetails.pressure = String.valueOf(currentDetails.get('pressure_in'));
        weatherDetails.humidity = String.valueOf(currentDetails.get('humidity'));
        weatherDetails.feelsLike = String.valueOf(currentDetails.get('feelslike_c'));

        // Extract condition details
        Map<String, Object> conditionDetails = (Map<String, Object>) currentDetails.get('condition');
        weatherDetails.icon = (String) conditionDetails.get('icon');
        weatherDetails.currentText = (String) conditionDetails.get('text');

        return weatherDetails;
    }

    // Wrapper class to hold the weather details
    public class WeatherDetails {
        @AuraEnabled public String cityName { get; set; }
        @AuraEnabled public String localTime { get; set; }
        @AuraEnabled public String temperature { get; set; }
        @AuraEnabled public String pressure { get; set; }
        @AuraEnabled public String humidity { get; set; }
        @AuraEnabled public String feelsLike { get; set; }
        @AuraEnabled public String icon { get; set; }
        @AuraEnabled public String currentText { get; set; }
    }
}