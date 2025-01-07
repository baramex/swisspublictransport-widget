import Toybox.System;
import Toybox.Communications;
import Toybox.Lang;

class JsonTransaction {
    static function makeRequest(method as String, params as Dictionary?, callback as Method) as Void {
        var url = "https://sbb.baramex.me" + method;                         // set the url

        var options = {                                             // set the options
            :method => Communications.HTTP_REQUEST_METHOD_GET,      // set HTTP method
            :headers => {                                           // set headers
                "Authorization" => "Bearer bMiCkxtO7TiLEC53zmwoEy4d2xRyrwKlmjQcVdnmMFmFo1V23vwRSzCT8MBG3IvN2m9kwi77haS9TO63mNaDCc3TeCETwghasVo6KMGYDytGqssI66oXN0Mh8Fbgk8gj"
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON       // set response type
        };

        Communications.makeWebRequest(url, params, options, callback);
    }
}