HTML Pack for Node
==================

Turns this...

```html
<!DOCTYPE html>
<html>
<head>
  <link rel="stylesheet" href="the.css">
</head>
<body>
  <script src="vendor/jquery.js"></script>
  <script src="the.js"></script>
</body>
</html>
```

...into this (reformatted slightly):

```html
<!DOCTYPE html><html><head><style>/* contents of the.css, minified */</style><body>
<script>/* contents of jquery then contents of the.js, minified */</script></body></html>
```

Here's how:

```js
var path = require("path");
var pack = require("html-pack");

pack(path.resolve(__dirname, "index.html"), function(err, html) {
  console.log("index.html, inlined and minified:");
  console.log(html);
});
```
