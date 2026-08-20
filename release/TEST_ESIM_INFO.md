# eSIM test inputs (MTR-003)

Free eSIM options for validating the eSIM/LPA path on metroid. No carrier
purchase required. Source: AOSP docs, 2026-06-17
(`source.android.com/docs/core/connect/esim-test-profiles`) and public carrier
trials.

## AOSP TS.48 v2 profiles (Google SM-DP+; compatibility probe only)

Google's test SM-DP+ (`prod.smdp-plus.rsp.goog`) publishes TS.48 v2 test
profiles. These codes are deprecated and are not a general-purpose profile
source for arbitrary production eUICCs. Enter an activation code manually in
Settings > Network & internet > SIMs > Add SIM > Download a SIM instead /
enter activation code. A compatible card can exercise profile download,
enable/disable, deletion, and reboot persistence.

| Profile | Activation code |
|---|---|
| TS48 V2 SAIP2.1 NoBERTLV (tested on compatible device) | `1$prod.smdp-plus.rsp.goog$3TD6-8L82-HUE1-LVN6` |
| TS48 V2 SAIP2.1 BERTLV | `1$prod.smdp-plus.rsp.goog$052X-UFXS-CQIY-PNGL` |
| TS48 V2 SAIP2.3 NoBERTLV | `1$prod.smdp-plus.rsp.goog$9RS2-4AT0-MPKU-HKUO` |
| TS48 V2 SAIP2.3 BERTLV | `1$prod.smdp-plus.rsp.goog$15YQ-Q0XO-9BN6-KSX2` |

Constraint: the eUICC and SM-DP+ must share a supported GSMA CI public-key
identifier. A retail or production-certificate card can still be incompatible
with Google's test SM-DP+.

r44 measured result, 2026-08-20: the SAIP2.1 NoBERTLV code reached Google's
SM-DP+ over HTTP 200 after successful local eUICC/APDU access, then failed at
InitiateAuthentication with GSMA subject/reason `8.8.2/3.1`: none of the CI
public-key identifiers proposed by the eUICC was supported by the SM-DP+.
The card remained blank. This accepts local discovery, LPA, APDU and network
transport but cannot test profile enablement or carrier packet data.

For repeatable lab profile management, use an SGP.26 test-certificate eUICC
with a matching test SM-DP+ such as sysmocom's service or `osmo-smdpp`. For
registration, data, calls and SMS, use a provisioned commercial profile or
physical SIM; TS.48 lab profiles do not provide commercial service.

## Fallback: free US carrier trials

Carrier trial apps check IMEI eligibility; a Nothing Phone 3 may or may not
be approved.

- AT&T 7-day free trial, unlimited US data/calls/texts, via AT&T app
- Verizon 30-day free trial, US only
- T-Mobile 3-month free trial, US only
- Google Fi 30-day free trial (~15 GB), needs a Google account

## Privacy rule

Never print or publish the device EID or any activation credential
(AGENTS.md / BUGS.md MTR-003).
