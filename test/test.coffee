path = require "path"
cheerio = require "cheerio"
expect = require("chai").expect

pack = require ".."

describe "html packer", ->

  result = null
  $ = null

  before (done) ->
    file = path.resolve(__dirname, "testpage/index.html")
    pack file, (err, response) ->
      return done(err) if err
      result = response
      $ = cheerio.load result
      done()

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
    expect($("script")).to.have.length 2

  it "minifies the styles", ->
    expected = """
      html{font-family:sans-serif}
      body{background-color:#903}
      .something{font-weight:700}
      """.replace(/\s/g, "")
    expect($("style").html()).to.equal expected

  it "minifies the first script", ->
    expected = '!function(){var o="hello";console.log(o)}();'
    expect($("script").first().html()).to.equal expected

  it "minifies the second scripts", ->
    expected = '!function(){var o="hello";console.log(o)}();'
    expected = """
      console.log("woah!");
      function aSweetFrigginFunction(){
      console.log("this function is SWEET")}
      function anotherSweetFrigginFunction(){
      console.log("Wow, this function is sweet too")}
      """.replace(/\n/g, "")
    expect($("script").last().html()).to.equal expected
