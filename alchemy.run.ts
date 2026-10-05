import * as Alchemy from "alchemy";
import * as Cloudflare from "alchemy/Cloudflare";
import * as GitHub from "alchemy/GitHub";
import * as Output from "alchemy/Output";
import { Config, Effect, Layer, Match, Schema } from "effect";

const Domain = Effect.gen(function* () {
  const zone = yield* Cloudflare.Zone.Zone("Zone", { name: "haoxiangliew.dev" });
  const { zoneId } = zone;

  yield* Cloudflare.Registrar.Domain("Registration", {
    domainName: "haoxiangliew.dev",
    autoRenew: true,
    locked: true,
    privacy: true,
  });
  yield* Cloudflare.DNS.Dnssec("Dnssec", { zoneId });

  yield* Cloudflare.DNS.Record("GoogleSiteVerification", {
    zoneId,
    name: "haoxiangliew.dev",
    type: "TXT",
    content: '"google-site-verification=dbrJkYmdjQgA87JGDZfOJVl2nmXB8KDr2huXMy1yRX0"',
  });

  yield* Cloudflare.DNS.Record("NullMx", {
    zoneId,
    name: "haoxiangliew.dev",
    type: "MX",
    content: ".",
    priority: 0,
  });
  yield* Cloudflare.DNS.Record("Dmarc", {
    zoneId,
    name: "_dmarc.haoxiangliew.dev",
    type: "TXT",
    content: '"v=DMARC1; p=reject;"',
  });

  yield* Effect.forEach(
    [
      ["always_use_https", "on"],
      ["min_tls_version", "1.2"],
      ["rocket_loader", "off"],
      ["browser_cache_ttl", 0],
      ["hotlink_protection", "on"],
      ["tls_client_auth", "on"],
      [
        "security_header",
        {
          strict_transport_security: {
            enabled: true,
            max_age: 15552000,
            include_subdomains: true,
            preload: true,
            nosniff: true,
          },
        },
      ],
    ] as const,
    ([settingId, value]) => Cloudflare.Zone.Setting(settingId, { zoneId, settingId, value }),
    { discard: true },
  );

  yield* Cloudflare.Argo.TieredCaching("TieredCaching", { zoneId, enabled: true });
  yield* Cloudflare.Cache.SmartTieredCache("SmartTieredCache", { zoneId, enabled: true });
  yield* Cloudflare.PageShield.Settings("PageShield", { zoneId, enabled: true });

  yield* Cloudflare.BotManagement.BotManagement("Bots", {
    zoneId,
    fightMode: false,
    enableJs: false,
    crawlerProtection: "enabled",
    isRobotsTxtManaged: true,
  });

  yield* Cloudflare.Ruleset.Ruleset("FirewallCustom", {
    zone,
    phase: "http_request_firewall_custom",
    rules: [],
  });

  return zone;
}).pipe(Alchemy.AdoptPolicy.adopt());

const planDetails = (stage: string, log: string) => {
  const plan = log.replace(/^\[[\d:.]+\] \w+ \(#\d+\): /gm, "").trim();
  const summary = plan.match(/^(Plan:|Planning failed).*$/m)?.[0] ?? "No plan output";
  return [
    `<details><summary><b>${stage}</b>: ${summary}</summary>`,
    "",
    "```",
    plan,
    "```",
    "",
    "</details>",
  ].join("\n");
};

export default Alchemy.Stack(
  "Website",
  {
    providers: Layer.mergeAll(Cloudflare.providers(), GitHub.providers()),
    state: Cloudflare.state(),
  },
  Effect.gen(function* () {
    const { stage } = yield* Alchemy.Stack;

    const website = yield* Match.value(stage).pipe(
      Match.when("prod", () =>
        Domain.pipe(
          Effect.flatMap(({ zoneId }) =>
            Cloudflare.Website.SvelteKit("Website", {
              domain: {
                name: "haoxiangliew.dev",
                redirects: ["www.haoxiangliew.dev"],
                zoneId,
              },
              workersDev: false,
            }),
          ),
        ),
      ),
      Match.when(
        (stage) => stage === "staging" || /^pr-\d+$/.test(stage),
        (stage) =>
          Config.Array(Schema.Trim, "ACCESS_EMAILS").pipe(
            Effect.flatMap((emails) =>
              Cloudflare.Website.SvelteKit("Website", {
                domain: `${stage}.haoxiangliew.dev`,
                workersDev: false,
                access: {
                  name: `${stage}.haoxiangliew.dev`,
                  policies: [{ decision: "allow", include: emails.map((email) => ({ email })) }],
                },
              }),
            ),
          ),
      ),
      Match.orElse(() => Cloudflare.Website.SvelteKit("Website")),
    );

    const github = yield* GitHub.GitHubEnv;
    if (github?.pr) {
      const plans = yield* Config.all({
        sha: Config.String("HEAD_SHA"),
        staging: Config.String("PLAN_STAGING"),
        prod: Config.String("PLAN_PROD"),
      });
      yield* GitHub.Comment("Preview", {
        owner: github.owner,
        repository: github.repository,
        issueNumber: github.pr,
        body: website.url.pipe(
          Output.mapEffect((url) =>
            Effect.fromNullishOr(url).pipe(
              Effect.orDie,
              Effect.map((url) =>
                [
                  `### Preview for ${plans.sha.slice(0, 7)}`,
                  "",
                  url,
                  "",
                  planDetails("staging", plans.staging),
                  "",
                  planDetails("prod", plans.prod),
                ].join("\n"),
              ),
            ),
          ),
        ),
      });
    }

    return { url: website.url };
  }),
);
