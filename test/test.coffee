path = require "path"
cheerio = require "cheerio"
expect = require("chai").expect

pack = require ".."

describe "html packer", ->

  result = null
  $ = null

  beforeEach (done) ->
    file = path.resolve(__dirname, "testpage/index.html")
    pack file, (err, response) ->
      return done(err) if err
      result = response
      $ = cheerio.load result
      done()

  afterEach ->
    result = null
    $ = null

  it "keeps the doctype", ->
    expect(result).to.match /^<!doctype html>/i

  it "has all the non-modified elements", ->
    expect($("html")).to.have.length 1
    expect($("head")).to.have.length 1
    expect($("body")).to.have.length 1
    expect($("meta[charset='utf-8']")).to.have.length 1
    expect($("title")).to.have.length 1
    expect($("title").html()).to.equal "test file"

  it "has the new elements, removing old ones", ->
    expect($("link")).to.have.length 0
    expect($("style")).to.have.length 1
    expect($("img")).to.have.length 1
    expect($("img").attr("alt")).to.equal "men with donkey"
    expect($("script")).to.have.length 2

###
<!DOCTYPE html>
<html>

<head>
  <meta charset="utf-8">
  <title>test file</title>
  <link rel="stylesheet" href="one.css">
  <link rel="stylesheet" href="inner/two.css">
</head>

<body>

  check out this sweet photo

  <img src="men_with_donkey.jpg" alt="men with donkey">

  <script src="one.js"></script>
  <script src="inner/two.js"></script>

</body>
</html>
###
