request = Npm.require('request');
parser = Npm.require('rssparser');

addFeed = function (url, callback) {
  parser.parseURL(url, {}, callback);
};

