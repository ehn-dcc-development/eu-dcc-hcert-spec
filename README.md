[![CC BY 4.0][cc-by-shield]][cc-by]

# Electronic Health Certificates

This repository contains a proposal for encoding and signing Electronic Health Certificates (EHC), as a candidate to be adapted and adopted by eHealth authorities and other stakeholders as they seem fit.


## Specification

[A draft specification is available](hcert_spec.md).

## Overview

![overview](overview.png)

## Requirements and Design Principles

The following requirements and principles has been used when designing the Electronic Health Certificates (EHC):

  1. Electronic Health Certificates shall be carried by the holder and must have the ability to be securely validated off-line (using strong and proven cryptographic primitives).

     *Example: Signed data with machine readable content.*

  2. Use an as compact encoding as practically possible, taking other requirements into consideration, to ensure reliable decoding using optical means.

     *Example: CBOR in combination with deflate compression and Aztec encoding.*

  3. Use existing, proven and modern open standards, with running code available (when possible) for all common platforms and operating environments to limit implementation efforts and minimise risk of interoperability issues.

     *Example: CBOR Web Tokens (CWT).*

  4. When existing standards does not exist, define and test new mechanisms based on existing mechanisms and ensure running code exists.

     *Example: Base45 encoding per new Internet Draft.*

  5. Ensure compatibility with existing systems for optical decoding.

     *Example: Base45 encoding for optical transport.*

## Trust model

The trust model is currently under development. It is assumed to be a Health specific version of the ICOA Master List concept (see also https://www.who.int/publications/m/item/interim-guidance-for-developing-a-smart-vaccination-certificate) that is Health and COVID specific.

The core of this consists of a simple (at this time, one layer deep) list of Country Signing Certificate Authorities (CSCA) that sign Document Signer Certificates (DSC). These are then used to sign the above mentioned digital health certificates.

The list of trusted keys used by verifiers will include a number of public keys together with issuer metadata. The keys used to sign the HCERTs are included on the Trusted List, there are no CAs or other intermediate parties 
involved in the validation process in the verifier. If CSCAs public keys appear in the list - they are _only_ there to facilitate the creation of the trusted list of public keys itself. They are not used during verification of a HCERT (as this is generally offline -- and purely based on the trusted list of that day).


## Known Implemenations

- [hcert test tool by Kirei AB](https://github.com/kirei/hcert)

Highly simplified JSON/CBOR/COSE/Zlib/Base45 pipelines:

- [javascript](https://github.com/ehn-digital-green-development/ehn-sign-verify-javascript-trivial)
- [python3](https://github.com/ehn-digital-green-development/ehn-sign-verify-python-trivial)

## Base45

Qr and Aztec code have a specific, highly efficient, method for storing alphanumeric characters (MODE 2/0010). In particular compared to UTF-8 (where the first 32 characters are essentially unused; and successive non-latin characters loose an additional 128 values as the topbit needs to be set).

Details of this 11 bits per two characters can be found at

-	 https://www.thonky.com/qr-code-tutorial/alphanumeric-mode-encoding
-	https://raw.githubusercontent.com/yansikeim/QR-Code/master/ISO%20IEC%2018004%202015%20Standard.pdf - section 7.44 on page 26

For this reason - the industry generally encodes these in base45. A document for this defacto standard is in flight:

- https://datatracker.ietf.org/doc/draft-faltstrom-base45/

## Presentation

[A short presentation on the background of this initative is available](https://github.com/kirei/hcert/blob/main/hcert-preso.pdf).


## Contributions

Contributions are very welcome - please file a pull request.

_________________

This work is licensed under a [Creative Commons Attribution 4.0 International License][cc-by].

[![CC BY 4.0][cc-by-image]][cc-by]

[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-image]: https://i.creativecommons.org/l/by/4.0/88x31.png
[cc-by-shield]: https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg
> 
