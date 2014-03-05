# Digipost for iOS

[![Digipost for iOS](https://i.imgur.com/vce3NJf.png)](http://itunes.apple.com/no/app/digipost/id441997544?mt=8&uo=4)

Digipost for iOS er en app for iOS på iPhone og iPad som gir tilgang til brukerens sikre digitale postkasse i Digipost. For å logge inn i appen trenger du en konto i Digipost, dette kan du opprette på [digipost.no](https://www.digipost.no/).

App-en i ferdig bygd versjon kan [lastes ned fra App Store](http://itunes.apple.com/no/app/digipost/id441997544?mt=8&uo=4).

Kildekoden er her tilgjengelig som fri programvare under lisensen *Apache License, Version 2.0*, som beskrevet i [lisensfilen](https://github.com/digipost/ios/blob/master/LICENSE "LICENSE").

Bilder og logoer for Posten og Digipost er (C) Posten Norge AS og er ikke lisensiert under Apache Licence, Versjon 2.0.

## Hvordan komme i gang

### 1. Skaffe tilgang til OAuth API

Denne applikasjonen bruker Digipost's OAuth API. For å kunne bruke dette API'et må du registrere en OAuth Consumer. Les mer om hvordan du gjør dette i [Digipost' API-dokumentasjon](https://www.digipost.no/plattform/privat/).

Når du har registrert denne applikasjonen, og fått en client-id og en oauth-secret, så lager du en kopi av filen `oauth.example.h`, fyller ut med dine verdier og navngir filen `oauth.h`.

### 2. Sette opp prosjekt

Digipost for iOS bruker Cocoapods, du må ha dette installert for å kunne bygge prosjektet. Installasjonsguide finnes [her](http://guides.cocoapods.org/using/getting-started.html).
Etter det er installert, gå til prosjektets mappe i terminalen og skriv
```
pod install
```


