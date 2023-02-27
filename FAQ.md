# Frequently Asked Questions

## What is an Electronic Health Certificate?

A Electronic Health Certificate contains health information (vaccinations, test results, recovery statements) about a specific person (subject). The information is electronically signed by the issuer (e.g. a country). It also contains information about issuing country, signing key identifier, time of issuing and expiration time.

## How can Electronic Health Certificate be transported?

The initial specification defines two transport encodings:

- *Raw* is used in APIs and contains a "CBOR Web Token" (CWT) as defined in [RFC 8392](https://tools.ietf.org/html/rfc8392). It is used mainly by APIs, but could also be used for binary transports like NFC and BLE.

- *Barcode* is used for mobile apps and paper and contains a [Base45](https://datatracker.ietf.org/doc/draft-faltstrom-base45) encoded compressed CWT. This encoding is not be used outside the optical transport context, and should be decoded and decompressed after scanning.

## Who defines the Health Certificate payload?

## Who issues Health Certificates?

## What does an issuer need to issue Health Certificates?

## What tasks lies on the Health Certificates issuer?

## What is required to verify a Health Certificate?

In order to verify a Health Certificate, the following components are required:

- A health certificate (normally scanned from Aztec or QR)
- A list of trusted signing keys together with issuer information
- A validation policy describing whether a health certificate is acceptable or not

## What does a mobile app developer (verifier) need to do?

1. Scan and decode
   1. Scan optical code (Aztec or QR)
   2. Check for leading "HC1" preamble
   3. Decode remaining payload (including spaces) using Base45
   4. Decompress decoded data (the decoded data includes a compression header)
2. Check CWT
   1. Parse decompressed data as a CWT
   2. Verify CWT against all trusted keys (using kid from CWT protected as hint)
   3. Find issuer metadata in list of trusted keys
   4. Check CWT claims (`iat`/`exp`)
3. Extract CWT `hcert` claim
4. Check Health Certificate payload
   1. Match Health Certificate subject with physical person (identity check)
   2. Evaluate Health Certificate (vaccination, test results, recovery statement)

# Author

This document was originally authored by [jschlyter](https://github.com/jschlyter) in the [github wiki](https://github.com/ehn-dcc-development/eu-dcc-hcert-spec.wiki.git) and was moved to the main github repository by the team to ensure that it is properly archived.