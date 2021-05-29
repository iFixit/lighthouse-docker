module.exports = {
	extends: 'lighthouse:default',
	settings: {
		maxWaitForFcp: min(1),
		maxWaitForLoad: min(2),
		skipAudits: ['uses-http2', 'full-page-screenshot'],
	}
}

function min(n) {
	return n * 60 * 1000;
}
