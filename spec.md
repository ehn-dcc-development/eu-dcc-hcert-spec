# Electronic Health Certificate Specification

Version 0.1.3, 2021-03-30.


## Abstract

This document specifies a data structure and encoding mechanisms for electronic health certificates. It also specifies a transport encoding mechanism in a machine-readable optical format (Aztec), which can be displayed on the screen of a mobile device or printed on a piece of paper.


## Terminology

Organisations adopting this specification for issuing health certificates are called Issuers and organisations accepting health certificates as proof of health status is called Verifiers. Together, these are called Participants. Some aspects in this document must be coordinated between the Participants, such as the management of a name space and the distribution of cryptographic keys. It is assumed that a party, hereafter referred to as the Coordinator, carries out these tasks. The health certificate format of this specification is called the Electronic Health Certificate, hereafter referred to as the EHC.

The keywords "MUST", "MUST NOT", "REQUIRED", "SHOULD", "SHOULD NOT", "RECOMMENDED" and "MAY" should be interpreted as described in ([RFC 2119](https://tools.ietf.org/html/rfc2119)).


### Versioning Policy

Versions of this specification follow semantic versioning (semver.org) and consist of three different integers describing the _major_, _minor_ and _edition_ version. A change in the _major_ version is an update that includes material changes affecting the decoding of the EHC or the validation of it. An update of the _minor_ version is a feature or maintenance update that maintains backward compatibility with previous versions.

In addition, there is an _edition_ version number used for publishing updates to the document itself which have no effect on the EHC, such as correcting spelling, providing clarifications or addressing ambiguities, et cetera. Hence, the edition number is not indicated in the EHC. The version numbers are expressed in the title page of the document using a _major.minor.edition_ format, where the three parts are separated by decimal dots.


## Electronic Health Certificate

The Electronic Health Certificate (EHC) is designed to provide a uniform and standardised vehicle for health certificates from different Issuers. The aim is to harmonise how these health certificates are represented, encoded and signed with the goal of facilitating interoperability, while protecting the holder’s personal integrity and minimise costs in implementation.


### Coordinated Data Structure

Ability to read and interpret EHCs issued by any Issuer requires a common data structure and agreements of the significance of each data field. To facilitate such interoperability, a common coordinated data structure is defined through the use of a JSON schema, Appendix A. Critical elements of a health certificate SHOULD use this data structure. A Participant MAY extend the objects with proprietary data. The naming of such objects MUST be agreed between all Participants.


### Structure of the Electronic Health Certificate

The EHC is structured and encoded as a CBOR Web Token (CWT) as defined in [RFC 8392](https://tools.ietf.org/html/rfc8392). The EHC payloads, as defined below, is transported in a hcert claim (claim key TBD).

The integrity and authenticity of origin of EHC data, the CWT MUST be verifiable by the Verifier. To provide this mechanism, the issuer of the EHC MUST sign the CWT using an asymmetric electronic signature scheme as defined in the COSE specification ([RFC 8152](https://tools.ietf.org/html/rfc8152)).


### CWT Claims

#### CWT Structure Overview

- Protected Header
  - Signature Algorithm (`alg`, label 1)
  - Key Identifier (`kid`, label 4)
- Payload
  - Issuer (`iss`, claim key 1, optional, ISO 3166 Country Code of issuer)
  - Issued At (`iat`, claim key 6)
  - Expiration Time (`exp`, claim key 4)
  - Health Certificate (`hcert`, claim key TBD)
    - EU Health Certficate v1 (`eu_hcert_v1`, claim key 1)
- Signature


#### Signature Algorithm

The Signature Algorithm (**alg**) parameter indicates what algorithm is used for the creating the signature. It must meet or exceed current SOG-IT guidelines.

One primary and one secondary algorithm is defined. The secondary algorithm should only be used if the primary algorithm is not acceptable within the rules and regulations imposed on the implementor.

However, it is essential and of utmost importance for the security of the system that all implementations incorporate the secondary algorithm. For this reason, both the primary and the secondary algorithm MUST be implemented.

For this version of the specification - the SOG-IT set levels for the primary and secondary algorithms are:

- Primary Algorithm: The primary algorithm is Elliptic Curve Digital Signature Algorithm (ECDSA) as defined in (ISO/IEC 14888–3:2006) section 2.3, using the P–256 parameters as defined in appendix D (D.1.2.3) of (FIPS PUB 186–4) in combination the SHA–256 hash algorithm as defined in (ISO/IEC 10118–3:2004) function 4.

This corresponds to the COSE algorithm parameter **ES256**.

- Fallback Algorithm: The fallback algorithm is RSASSA-PKCS#1 v1.5 as defined in ([RFC 3447](https://tools.ietf.org/html/rfc3447)) with a modulus of 2048 bits in combination with the SHA–256 hash algorithm as defined in (ISO/IEC 10118–3:2004) function 4.

This corresponds to the COSE algorithm parameter: **RS256**

#### Key Identifier

The Key Identifier (**kid**) claim is used by Verifiers for selecting the correct public key from a list of keys pertaining to the Issuer (**iss**) Claim. Several keys may be used in parallel by an Issuer for administrative reasons and when performing key rollovers.The Key Identifier is not a security-critical field. For this reason, it MAY also be placed in an unprotected header if required. Verifiers MUST accept both options.

####  Issuer

The Issuer (**iss**) claim is a string value which MAY hold the identifier of the entity issuing the EHC. The namespace of the Issuer Identifiers MUST be agreed between the Participants, but is not defined in the specification.
The Claim Key 1 is used to identify this claim.

#### Expiration Time

The Expiration Time (**exp**) claim SHALL hold a timestamp in the NumericDate format (as specified in [RFC 8392](https://tools.ietf.org/html/rfc8392) section 2) indicating for how long this particular signature over the Payload SHALL be considered valid, after which a Verifier MUST reject the Payload as expired. The purpose of the expiry parameter is to force a limit of the validity period of the EHC. The Claim Key 4 is used to identify this claim.


#### Issued At

The Issued At (**ia**t) claim SHALL hold a timestamp in the NumericDate format (as specified in [RFC 8392](https://tools.ietf.org/html/rfc8392) section 2) indicating the time when the EHC was created. Verifiers MAY apply policies with the purpose of restricting the validity of the EHC based on the time of issue. The Claim Key 6 is used to identify this claim.


#### Health Certificate Claim

The Health Certificate (**hcert**) claim is a JSON ([RFC 7159](https://tools.ietf.org/html/rfc7159)) object containing the health status information, which has been encoded and serialised using CBOR as defined in ([RFC 7049](https://tools.ietf.org/html/rfc7049)). Several EHCs MAY exist under the same claim.

The Claim Key to be used to identify this claim is yet to be determined.

Strings in the JSON object SHOULD be NFC normalised according to the Unicode standard. Decoding applications SHOULD however be permissive and robust in these aspects, and acceptance of any reasonable type conversion is strongly encouraged. If unnormalised data is found during decoding, or in subsequent comparison function, implementations SHOULD behave as if the input is normalised to NFC.


## Transport Encodings

### Raw

For arbitrary data interfaces the EHC may be transferred as-is, utilising any underlying reliable data transport. These interfaces MAY include NFC, Bluetooth or transfer over an application layer protocol, for example transfer of an EHC from the Issuer to a holder’s mobile device.

If the transfer of the EHC from the Issuer to the holder is based on a presentation-only interface (e.g., SMS, e-mail), the Raw transport encoding is obviously not applicable.

### Barcode

To lower size and to improve speed and reliability in the reading process of the EHC, the CWT SHALL be compressed using ZLIB ([RFC 1950](https://tools.ietf.org/html/rfc1950)) and the Deflate compression mechanism in the format defined in ([RFC 1951](https://tools.ietf.org/html/rfc1951)). In order to better handle legacy equipment designed to operate on ASCII payloads, the compressed CWT is encoded as ASCII using [Base45](https://datatracker.ietf.org/doc/draft-faltstrom-base45) before encoded into a barcode.

Two barcode formats are supported; AZTEC (preferred) and QR (secondary). The optical code is RECOMMENDED to be rendered on the presentation media with a diagonal size between 35 mm and 65 mm.

In order for readers to be able to detect optical payload content type, the base45 encoded data per this specification SHALL be prefixed by the string "HC1".

#### AZTEC 2D Barcode

To optically represent the EHC using a compact machine-readable format the Aztec 2D Barcode (ISO/IEC 24778:2008) SHOULD be used.

When generating the optical code with Aztec, an error correction rate of 23% is RECOMMENDED. 


#### QR 2D Barcode

Alternatively a QR barcode may be used. An error correction rate of ‘Q’ (around 25%) recommended. 


## Security Considerations

When designing a scheme using this specification, several important security aspects must be considered. These can not preemptively be accounted for in this specification, but must be identified, analysed and monitored by the Participants.

As input to the continuous analysis and monitoring of risks, the following topics SHOULD be taken into account:

### EHC Validity Time

It is anticipated that EHCs can not be reliably revoked once issued, especially not if this specification would be used on a global scale. Mainly for this reason, this specification requires the Issuer of an EHC to limit the EHC’s validity period by specifying an expiry time. This requires to holder of an EHC to renew the EHC on some regular basis. 

The acceptable validity period would be determined by practical constraints, a traveller may not have the possibility to renew the EHC during a travel overseas. But it may also be that an Issuer of EHC’s are considering the possibility of a security compromise of some sort, which requires the Issuer to withdraw an Issuer Key (invalidating all EHCs signed using that key). The consequences of such an event may be limited by regularly rolling Issuer keys and requiring renewal of all EHCs, on some reasonable interval.


### Key Management

This specification relies heavily on strong cryptographic mechanisms to secure data integrity and data origin authentication. Maintaining the confidentiality of the private encryption keys are therefor of utmost importance.

The confidentiality of cryptographic keys can be compromised in a number of different ways, for instance;

- The key generation process may be flawed, resulting in weak keys.
- The keys may be exposed by human error.
- The keys may be stolen by external or internal perpetrators.
- The keys may be calculated using cryptanalysis.

To mitigate against the risks that the signing algorithm is found to be weak, allowing the private keys to be compromised through cryptanalysis, this specification recommends all Participants to implement a fallback signature algorithm based on different parameters or a different mathematical problem than the primary.

The other risks mentioned here are related to the Issuers' operating environments. One effective control to mitigate significant parts of these risks is to generate, store and use the private keys in Hardware Security Modules (HSMs). Use of HSMs for signing EHCs is highly encouraged.

However, regardless if an Issuer decides to use HSMs or not, a key roll-over schedule SHOULD be established where the frequency of the key roll-overs is proportionate to the exposure of keys to external networks, other systems and personnel. A well-chosen roll-over schedule also limits the risks associated with erroneously issued EHCs, enabling an Issuer to revoke such EHCs in batches, by withdrawing a key, if required.


### Input Data Validation

This specification may be used in a way which implies receiving data from untrusted sources into systems which may be of mission-critical nature. To minimise the risks associated with this attack vector, all input fields MUST be properly validated by data types, lengths and contents. The Issuer Signature SHALL also be verified before any processing of the contents of the EHC takes place. However, the validation of the Issuer Signature implies parsing the Protected Issuer Header first, in which a potential attacker may attempt to inject carefully crafted information designed to compromise the security of the system.


## Appendix A

([hcert_schema](https://raw.githubusercontent.com/kirei/hcert/main/hcert_schema.yaml))

_________________

- Fredrik Ljunggren, Kirei AB.
- Jakob Schlyter, Kirei AB
- Dirk-Willem van Gulik
- Martin Lindström, iDsec Solutions AB



[![CC BY 4.0][cc-by-shield]][cc-by]

This work is licensed under a
[Creative Commons Attribution 4.0 International License][cc-by].

[![CC BY 4.0][cc-by-image]][cc-by]

[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-image]: https://i.creativecommons.org/l/by/4.0/88x31.png
[cc-by-shield]: https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg
