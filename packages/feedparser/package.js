Npm.depends({rssparser: '0.0.4'});

Package.on_use(function(api, where) {
  api.add_files(['feedparser.js'], 'server');
})

