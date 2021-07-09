module.exports = {
  extends: 'lighthouse:default',
  settings: {
    onlyCategories: ['performance'],
    maxWaitForFcp: min(1),
    maxWaitForLoad: min(2),
  }
}

function min(n) {
  return n * 60 * 1000;
}
