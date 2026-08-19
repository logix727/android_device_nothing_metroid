# eSIM test inputs (MTR-003)

Free eSIM options for validating the eSIM/LPA path on metroid. No carrier
purchase required. Source: AOSP docs, 2026-06-17
(`source.android.com/docs/core/connect/esim-test-profiles`) and public carrier
trials.

## Primary: AOSP downloadable TS.48 test profiles (Google SM-DP+)

Google's test SM-DP+ (`prod.smdp-plus.rsp.goog`) serves public TS.48 test
profiles with no download limits. Enter the activation code manually in
Settings > Network & internet > SIMs > Add SIM > Download a SIM instead /
enter activation code. These exercise profile download, enable/disable,
deletion, and reboot persistence.

| Profile | Activation code |
|---|---|
| TS48 V2 SAIP2.1 NoBERTLV (tested on compatible device) | `1$prod.smdp-plus.rsp.goog$3TD6-8L82-HUE1-LVN6` |
| TS48 V2 SAIP2.1 BERTLV | `1$prod.smdp-plus.rsp.goog$052X-UFXS-CQIY-PNGL` |
| TS48 V2 SAIP2.3 NoBERTLV | `1$prod.smdp-plus.rsp.goog$9RS2-4AT0-MPKU-HKUO` |
| TS48 V2 SAIP2.3 BERTLV | `1$prod.smdp-plus.rsp.goog$15YQ-Q0XO-9BN6-KSX2` |

Constraint: the downloading device must have a test certificate issued by a
GSMA CI. Retail eUICCs often ship production-only certs, so a download may
fail with a certificate error. That failure is still evidence: it confirms
eUICC discovery plus LPA bind work and isolates a cert gate rather than a
stack break. Start with the SAIP2.1 NoBERTLV code (marked tested).

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