module.exports = [
	{from: '/favicon.ico', to: '/static/favicon.ico'},
	{from: '/partials/*', to: '/partials/*'},
	{from: '/css/*', to: 'static/css/*'},
	{from: '/img/*', to: 'static/img/*'},
	{from: '/js/*', to: 'static/js/*'},
	{from: '/index.html', to: 'partials/index.html'},
	{from: '/modules.js', to: 'modules.js'},
	{from: '/', to: 'partials/index.html'},
	{from: ':db/:id', to: '../../../:db/:id'},
	{from: '/:db/_design/:dd/*', to: '../../../:db/_design/:dd/*'},
	{from: '/:db/:doc/:att', to: '../../../:db/:doc/:att'},
];
