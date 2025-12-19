# 03 - Splunk Hands-On

## Steps
- Launch Splunk (trial/local); set HEC token.
- Send CloudTrail JSON via HEC or UF.
- Create sourcetype with proper timestamp/fields.
- SPL examples:
  - `index=cloudtrail errorCode=* | stats count by errorCode`
  - `index=cloudtrail eventName=ConsoleLogin userIdentity.type=Root`

Alert: root login trigger email/webhook.