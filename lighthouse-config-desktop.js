const constants = require("/opt/lighthouse/node_modules/lighthouse/lighthouse-core/config/constants.js");

module.exports = {
  extends: "lighthouse:default",
  settings: {
    onlyCategories: ["performance"],
    skipAudits: [
      "full-page-screenshot",
      "screenshot-thumbnails",
      "final-screenshot"
    ],
    maxWaitForFcp: min(1),
    maxWaitForLoad: min(2),
    formFactor: "desktop",
    throttling: constants.throttling.desktopDense4G,
    screenEmulation: constants.screenEmulationMetrics.desktop,
    emulatedUserAgent: constants.userAgents.desktop
  }
};

function min(n) {
  return n * 60 * 1000;
}
