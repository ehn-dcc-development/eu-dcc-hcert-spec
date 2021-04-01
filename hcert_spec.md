# Electronic Health Certificate Specification

Version 0.1.4, 2021-04-06.


## Abstract

This document specifies a data structure and encoding mechanisms for electronic health certificates. It also specifies a transport encoding mechanism in a machine-readable optical format (Aztec), which can be displayed on the screen of a mobile device or printed on a piece of paper.


## Terminology

Organisations adopting this specification for issuing health certificates are called Issuers and organisations accepting health certificates as proof of health status is called Verifiers. Together, these are called Participants. Some aspects in this document must be coordinated between the Participants, such as the management of a name space and the distribution of cryptographic keys. It is assumed that a party, hereafter referred to as the Coordinator, carries out these tasks. The health certificate format of this specification is called the Electronic Health Certificate, hereafter referred to as the HCERT.

The keywords "MUST", "MUST NOT", "REQUIRED", "SHOULD", "SHOULD NOT", "RECOMMENDED" and "MAY" should be interpreted as described in ([RFC 2119](https://tools.ietf.org/html/rfc2119)).


### Versioning Policy

Versions of this specification follow semantic versioning (semver.org) and consist of three different integers describing the _major_, _minor_ and _edition_ version. A change in the _major_ version is an update that includes material changes affecting the decoding of the HCERT or the validation of it. An update of the _minor_ version is a feature or maintenance update that maintains backward compatibility with previous versions.

In addition, there is an _edition_ version number used for publishing updates to the document itself which have no effect on the HCERT, such as correcting spelling, providing clarifications or addressing ambiguities, et cetera. Hence, the edition number is not indicated in the HCERT. The version numbers are expressed in the title page of the document using a _major.minor.edition_ format, where the three parts are separated by decimal dots.


## Electronic Health Certificate

The Electronic Health Certificate (HCERT) is designed to provide a uniform and standardised vehicle for health certificates from different Issuers. The aim is to harmonise how these health certificates are represented, encoded and signed with the goal of facilitating interoperability, while protecting the holder’s personal integrity and minimise costs in implementation.


### Coordinated Data Structure

Ability to read and interpret HCERTs issued by any Issuer requires a common data structure and agreements of the significance of each data field. To facilitate such interoperability, a common coordinated data structure is defined through the use of a JSON schema, Appendix A. Critical elements of a health certificate SHOULD use this data structure. A Participant MAY extend the objects with proprietary data. The naming of such objects MUST be agreed between all Participants.

Note that the data structure is of importance here. The actual wire format is language neutral (CBOR and CWT (which itself CBOR again)).

### Structure of the Electronic Health Certificate

The HCERT is structured and encoded as a CBOR payload with a COSE digital signature. This is commonly known as a "CBOR Web Token" (CWT), and is defined in [RFC 8392](https://tools.ietf.org/html/rfc8392). The HCERT payloads, as defined below, is transported in a hcert claim (claim key TBD).

The integrity and authenticity of origin of HCERT data, the CWT MUST be verifiable by the Verifier. To provide this mechanism, the issuer of the HCERT MUST sign the CWT using an asymmetric electronic signature scheme as defined in the COSE specification ([RFC 8152](https://tools.ietf.org/html/rfc8152)).


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

- Fallback Algorithm: The fallback algorithm is RSASSA-PSS as defined in ([RFC 8230](https://tools.ietf.org/html/rfc8230)) with a modulus of 2048 bits in combination with the SHA–256 hash algorithm as defined in (ISO/IEC 10118–3:2004) function 4.

This corresponds to the COSE algorithm parameter: **PS256**

#### Key Identifier

The Key Identifier (**kid**) claim is used by Verifiers for selecting the correct public key from a list of keys pertaining to the Issuer (**iss**) Claim. Several keys may be used in parallel by an Issuer for administrative reasons and when performing key rollovers.The Key Identifier is not a security-critical field. For this reason, it MAY also be placed in an unprotected header if required. Verifiers MUST accept both options.

Due to this shortening of the identifier (for space preservin reasons) there is a non-finite chance that the overall list of DSCs accepted by an validator contains DSCs with duplicate KIDs. For this reason a verifier MUST check all DSCs with that KID.

####  Issuer

The Issuer (**iss**) claim is a string value which MAY hold the identifier of the entity issuing the HCERT. The namespace of the Issuer Identifiers MUST be agreed between the Participants, but is not defined in the specification.
The Claim Key 1 is used to identify this claim.

#### Expiration Time

The Expiration Time (**exp**) claim SHALL hold a timestamp in the NumericDate format (as specified in [RFC 8392](https://tools.ietf.org/html/rfc8392) section 2) indicating for how long this particular signature over the Payload SHALL be considered valid, after which a Verifier MUST reject the Payload as expired. The purpose of the expiry parameter is to force a limit of the validity period of the HCERT. The Claim Key 4 is used to identify this claim.

The Expiration Time MUST not exceed the validity time in the DSC.  The verifier SHOULD check this.

#### Issued At

The Issued At (**ia**t) claim SHALL hold a timestamp in the NumericDate format (as specified in [RFC 8392](https://tools.ietf.org/html/rfc8392) section 2) indicating the time when the HCERT was created. 

The Issued At  MUST not predate the validity time in the DSC.  The verifier MAY check this.

Verifiers MAY also apply additional policies with the purpose of restricting the validity of the HCERT based on the time of issue. The Claim Key 6 is used to identify this claim.

#### Health Certificate Claim

The Health Certificate (**hcert**) claim is a JSON ([RFC 7159](https://tools.ietf.org/html/rfc7159)) object containing the health status information, which has been encoded and serialised using CBOR as defined in ([RFC 7049](https://tools.ietf.org/html/rfc7049)). Several HCERTs MAY exist under the same claim.

Note here that the JSON is purely for schema purposes. The wire format is CBOR. Application developers may not actually ever de-, or encode to and from a JSON; but use the in memory structure.

The Claim Key to be used to identify this claim is yet to be determined.

Strings in the JSON object SHOULD be NFC normalised according to the Unicode standard. Decoding applications SHOULD however be permissive and robust in these aspects, and acceptance of any reasonable type conversion is strongly encouraged. If unnormalised data is found during decoding, or in subsequent comparison function, implementations SHOULD behave as if the input is normalised to NFC.

## Transport Encodings

### Raw

For arbitrary data interfaces the HCERT may be transferred as-is, utilising any underlying, 8 bit safe, reliable data transport. These interfaces MAY include NFC, Bluetooth or transfer over an application layer protocol, for example transfer of an HCERT from the Issuer to a holder’s mobile device.

If the transfer of the HCERT from the Issuer to the holder is based on a presentation-only interface (e.g., SMS, e-mail), the Raw transport encoding is obviously not applicable.

### Barcode

To lower size and to improve speed and reliability in the reading process of the HCERT, the CWT SHALL be compressed using ZLIB ([RFC 1950](https://tools.ietf.org/html/rfc1950)) and the Deflate compression mechanism in the format defined in ([RFC 1951](https://tools.ietf.org/html/rfc1951)). 

Verifiers MUST check of the presence of a valid ZLIB/Deflate header (0x78, 0xDA) - or proceed without this step when absent.

In order to better handle legacy equipment designed to operate on ASCII payloads, the compressed CWT is encoded as ASCII using [Base45](https://datatracker.ietf.org/doc/draft-faltstrom-base45) before encoded into a barcode.

Two barcode formats are supported; AZTEC (preferred) and QR (secondary). 

In order for readers to be able to detect optical payload content type, the base45 encoded data per this specification SHALL be prefixed by the string "HC1".

#### AZTEC 2D Barcode

To optically represent the HCERT using a compact machine-readable format the Aztec 2D Barcode (ISO/IEC 24778:2008) SHOULD be used.

When generating the optical code with Aztec, an error correction rate of 23% is RECOMMENDED. The optical code is RECOMMENDED to be rendered on the presentation media with a diagonal size between 35 mm and 65 mm.

#### QR 2D Barcode

Alternatively a QR barcode may be used. An error correction rate of ‘Q’ (around 25%) RECOMMENDED.  The Alphanumeric (Mode 2/QR Code symbols 0010) MUST be used in conjunction with Base45. 

The optical code is RECOMMENDED to be rendered on the presentation media with a diagonal size for at least 35 mm; and when used on an optical screen with at least 4 pixels per timing cell. (recommended and max size to be confirmed).

## Trusted List Format (DSC list)

Each country will provide a list of one or more CSCAs.

The CSCA and the trusted DSC list format will follow the format of the ICAO master list (ldif) with the public key pairs packaged into a X.509v3 certificate as a base64 encoder DER.

Each certificate:

- MUST contain A valid ‘C’ that matches the country of issuance.
- MUST contain a well managed, unique, DN and unique Serial number
- MUST contain a 256bit Authority (Issuer) key identifier
- MUST contain a 256bit Subject key identifier

In addition - each DSC certificate:

- MUST contain validity range that is in line or broader than the EHC Validity Time of all EHC periods signed by that key.
- SHOULD contain aX509v3 Private Key Usage Period period.
- MUST contain a 256bit Authority (Issuer) key identifier
- MUST contain a 256bit Subject key identifier

TBD.

It is expressly allowed to have the CSCA be identical to the DSC. Or in other words - if a country uses a set of self-signed certificates; it would submit these both as its CSCA’s and as its DSC list.

As of this version of the specifications - countries should NOT assume that any CRL information is used; or that the Private Key Usage Period is verified by implementors.

Instead - the primary validity mechanism is appearance on the most recent version of the list.


## Security Considerations

When designing a scheme using this specification, several important security aspects must be considered. These can not preemptively be accounted for in this specification, but must be identified, analysed and monitored by the Participants.

As input to the continuous analysis and monitoring of risks, the following topics SHOULD be taken into account:

### HCERT Validity Time

It is anticipated that HCERTs can not be reliably revoked once issued, especially not if this specification would be used on a global scale. Mainly for this reason, this specification requires the Issuer of an HCERT to limit the HCERT’s validity period by specifying an expiry time. This requires to holder of an HCERT to renew the HCERT on some regular basis. 

The acceptable validity period would be determined by practical constraints, a traveller may not have the possibility to renew the HCERT during a travel overseas. But it may also be that an Issuer of HCERT’s are considering the possibility of a security compromise of some sort, which requires the Issuer to withdraw an Issuer Key (invalidating all HCERTs signed using that key). The consequences of such an event may be limited by regularly rolling Issuer keys and requiring renewal of all HCERTs, on some reasonable interval.


### Key Management

This specification relies heavily on strong cryptographic mechanisms to secure data integrity and data origin authentication. Maintaining the confidentiality of the private encryption keys are therefor of utmost importance.

The confidentiality of cryptographic keys can be compromised in a number of different ways, for instance;

- The key generation process may be flawed, resulting in weak keys.
- The keys may be exposed by human error.
- The keys may be stolen by external or internal perpetrators.
- The keys may be calculated using cryptanalysis.

To mitigate against the risks that the signing algorithm is found to be weak, allowing the private keys to be compromised through cryptanalysis, this specification recommends all Participants to implement a fallback signature algorithm based on different parameters or a different mathematical problem than the primary.

The other risks mentioned here are related to the Issuers' operating environments. One effective control to mitigate significant parts of these risks is to generate, store and use the private keys in Hardware Security Modules (HSMs). Use of HSMs for signing HCERTs is highly encouraged.

However, regardless if an Issuer decides to use HSMs or not, a key roll-over schedule SHOULD be established where the frequency of the key roll-overs is proportionate to the exposure of keys to external networks, other systems and personnel. A well-chosen roll-over schedule also limits the risks associated with erroneously issued HCERTs, enabling an Issuer to revoke such HCERTs in batches, by withdrawing a key, if required.


### Input Data Validation

This specification may be used in a way which implies receiving data from untrusted sources into systems which may be of mission-critical nature. To minimise the risks associated with this attack vector, all input fields MUST be properly validated by data types, lengths and contents. The Issuer Signature SHALL also be verified before any processing of the contents of the HCERT takes place. However, the validation of the Issuer Signature implies parsing the Protected Issuer Header first, in which a potential attacker may attempt to inject carefully crafted information designed to compromise the security of the system.


# Appendix A - Payload

A proposed payload schema for [EU Health Certficate v1](eu_hcert_v1_schema.yaml).

# Appendix B - Trust management

The signature on the HCERT requires a public key to verify. Countries, or institutions within countries, need to place those signatures. And ultimately every verifier needs to have a list of the public keys it is willing to trust (the public key is not part of the signature).

For this a simplified variation on the ICAO "_Master list_: will be used, tailored to this health application. Where each country is ultimately responsible for compiling their own master list. But with the aid of a coordinating secretariat for operational and practical purposes.

The system consists of (just) two layers; for each Member State one or more country level certificate that each sign one or more document signing certificates that are used in day to day operations.

The member-state certificates are called Certificate Signer Certificate Authority (CSCA) certificates and are (typically) self signed certificates. Countries may have more than one (e.g. in case of regional devolution). 

Memberstates are required to keep a public register of these certificates at a stable URL.

Memberstates may then bilaterally exchange CSCA certificates with a number of other States, verify these bilaterally and thus compile their own lists of CSCA certificates: a (MS specific) Master List. 

These CSCA certificates regularly sign the Document Signing Certificates (DSC) used in day to day operations. Memberstates will each will maintain a public register of the DSC certificates that is kept current.

Other memberstates must regularly fetch these list of DSC certificates and cryptographically verify these against the CSCA certificates (that they have verified by other, non-digital, means).  

The resulting list of DSC certificates then provides the acceptable public keys (and the corresponding KIDs) that verifiers can use to validate the signature on the CWT in the Qr code. 

Verifiers should fetch update so this list regularly. Verifiers are expected to tune the format to this list for their own national setting; and the file format of this, internal, trusted list may vary, e.g. it can be a plain JWKS like https://github.com/ehn-digital-green-development/hcert-testdata/blob/main/testdata/jwks.json or something specific to the technology used.

### The Key Identifier (KIDs)

The key identifier consists of the final (TBD) 8 bytes of the SHA256 fingerprint of the DSC.

## Differences with the ICAO MasterList system for passports

While patterned on best practices of the ICAO Ml - there are a number of simplifications made in the interest of speed (and recognising the fact that the EU Regulation for EHN is sharply limited in time and scope).

* A Member-state may submit multiple CSCA certificates
* A CSCA certificate may also be used --and published as-- a DSC.
* The DSC (key usage) validity period may be set to any length not exceeding the CSCA.
* The DSC certificate MAY contain policy identifers that are EHN specific.

## Secretariat

In order to alleviate the burden of countries during the initial phase -- there shall be a secretarial service that will:

* Maintain a list of operational and legal contacts for each member-state to further orderly management of this health specific set of master lists.
* Maintain a public 24x7 an incident/security contact point.
* Maintain a public list of URLs with the most up to date CSCA lists for each member-state.
* Maintain a public  list of URLs with the most up to date DSC lists for each member-state.
* Maintain a public  single, aggregated, list of all CSCAs, that is updated daily.
* Maintain a public single, aggregated, list of all DSAs, that is updated daily.
* Provide MS with a secure (i.e. integrity protected) mechanism by which the Secretariat publishes the member states aggregated CSCA and DSC lists (CIRBAC, t.b.c)
* Shall validate the DSCs against the CSCA prior to publication.
* MAY sign the aggregated list.

The format for the lists used for the interchange between the member states and the Secretariat is TBC, and should be optimised for clarity and interoperability. The ICAO Master List structure as defined in Doc 9303 part 12 may be considered.

This list format for interchange between the member states is likely to be quite different from format of the list of DSCs downloaded by the verifiers on a daily basis from the field. The Secretariat should take care to publish the aggregated list of DSCs in an, from a verifiers perspective, accessible and easy to use format.

Member State are also expected to publish country-specific lists, in formats tuned to the technological setting at hand in that member state.

And that the Secretarial also will:

* Maintain a similar set of lists with 'test' certificates
* Maintain a set of test certificates - at least one for each country.

## Key Usage Policy Identifiers

The document signing certificate MAY contain Extended key usage extension fields; these being:

* OID 1.3.6.1.4.1.0.1847.2021.1.1        valid for test
* OID 1.3.6.1.4.1.0.1847.2021.1.2        valid for vacc
* OID 1.3.6.1.4.1.0.1847.2021.1.3        valid for recovery

And if not present - shall be considered valid for all three.


_________________

- Fredrik Ljunggren, Kirei AB.
- Jakob Schlyter, Kirei AB
- Dirk-Willem van Gulik - For the Ministry of Public Health of the Netherlands
- Martin Lindström, iDsec Solutions AB



[![CC BY 4.0][cc-by-shield]][cc-by]

This work is licensed under a
[Creative Commons Attribution 4.0 International License][cc-by].

[![CC BY 4.0][cc-by-image]][cc-by]

[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-image]: https://i.creativecommons.org/l/by/4.0/88x31.png
[cc-by-shield]: https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg
