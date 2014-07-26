var fs = require("fs");
var path = require("path");
var async = require("async");
var cheerio = require("cheerio");
var minify = require("html-minify").minify;
var splitLines = require("split-lines");

module.exports = function pack(file, callback) {

  fs.readFile(file, function(err, html) {

    if (err) {
      callback(err);
      return;
    }

    var $ = cheerio.load(html);
    var dirname = path.dirname(file);
    var elements = $("link[rel='stylesheet'], script[src]");

    async.each(elements, function(element, done) {

      var $element = $(element);

      var isCSS = element.name === "link";

      var src = $element.attr(isCSS ? "href" : "src");
      if (!src) {
        done();
      }
      var srcPath = path.resolve(dirname, src);

      fs.readFile(srcPath, function(err, contents) {

        if (err) {
          done(err);
          return;
        }

        var result;
        if (isCSS) {
          result = "<style>" + contents + "</style>";
        } else {
          result = "<script>" + contents + "</script>";
        }

        $element.replaceWith(result);

        done();

      });

    }, function(err) {

      if (err) {
        callback(err);
        return;
      }

      var minified = minify($.html());
      var lines = splitLines(minified);
      var combined = lines.reduce(function(prev, line) {
        return prev + line.trim();
      }, "");
      var html = combined
        .replace(/<\/script><script>/gi, "")
        .replace(/<\/style><style>/gi, "");
      callback(err, html);

    });

  });

};
