# 03 - Custom Rules, Rate Limits, Bot Control

## Custom Rules
- Block paths: `/(wp-admin|phpmyadmin|shell)`.
- Geo allow/deny by business region.
- IP set allowlist for admin routes.

## Rate Limiting
- WAF rate-based rule (e.g., 2000 req/5min per IP) on login/API routes.

## Bot Mitigation (lite)
- Use Bot Control (if licensed) or custom header check for automation.
- Challenge/JS injection for suspected bots via CAPTCHA rule action.

## Validation
- Run `ab`/`hey` to exceed rate; confirm throttling/block.

Outcome: Tailored protections for abuse, scraping, brute force.