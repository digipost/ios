# Digipost for iOS

[![Digipost for iOS](https://i.imgur.com/vce3NJf.png)](http://itunes.apple.com/no/app/digipost/id441997544?mt=8&uo=4)
[![Build Status](https://travis-ci.org/digipost/ios.svg?branch=develop)](https://travis-ci.org/digipost/ios)

Digipost for iOS er en app for iOS på iPhone, iPad og iPod Touch som gir tilgang til brukerens sikre digitale postkasse i Digipost. For å logge inn i appen trenger du en konto i Digipost, dette kan du opprette på [digipost.no](https://www.digipost.no/).

App-en i ferdig bygget versjon kan [lastes ned fra App Store](http://itunes.apple.com/no/app/digipost/id441997544?mt=8&uo=4).

## Kom i gang

### 1. Tilgang til OAuth API

Digipost for iOS bruker Digiposts OAuth API. For å kunne bruke dette API-et må du registrere en *OAuth Consumer*. Informasjon om hvordan du gjør dette finner du i [Digiposts API-dokumentasjon](https://www.digipost.no/plattform/api/).

Når du har registrert din nye applikasjon, og fått en *client-id* og en *oauth-secret*, lager du en kopi av filen `oauth.example.h`, fyller ut med dine verdier og lagrer filen som `oauth.h`.

### 2. Sett opp ditt prosjekt

Digipost for iOS bruker Cocoapods. Du må ha Cocoapods installert for å kunne bygge prosjektet. Installasjonsguide finnes [her](http://guides.cocoapods.org/using/getting-started.html).
Straks Cocoapods er installert, gå til prosjektets mappe i terminalen og skriv
```
pod install
```
Etter pod-ene er installert, åpne *.xcworkspace*-filen i Xcode. Prosjektet er nå klart til å bygges og kjøres i simulator.

Hvis du bruker rbenv og bundler er også Cocoapods versjonert i `Gemfile`. For å bruke en lokal versjon:

```
bundle install

./bin/pod install
```

## Systemkrav

Digipost for iOS er bygget for iOS versjon 8.


## Lisens

Kildekoden til Digipost for iOS er tilgjengelig som fri programvare under lisensen *Apache License, Version 2.0*, som beskrevet i [lisensfilen](https://github.com/digipost/ios/blob/master/LICENSE "LICENSE").

Bilder og logoer for Posten og Digipost er (C) Posten Norge AS og er ikke lisensiert under *Apache Licence, Versjon 2.0*.
