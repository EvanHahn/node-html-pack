var fs = require("fs");
var path = require("path");
var async = require("async");
var lines = require("split-lines");
var cheerio = require("cheerio");
var minify = require("html-minify").minify;

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

      var html = lines(minify($.html())).join("");
      console.log(html);
      callback(err, html);

    });

  });

};
