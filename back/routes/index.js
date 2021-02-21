var express = require('express');
const Crawler = require("crawler");
const cheerio = require('cheerio');
var router = express.Router();
/* GET home page. */

function testUrl(uri, url) {
  let urlTest1 = [
      url !== '',
      url !== '#',
      url !== undefined
  ];
  let returnValue = true;
  urlTest1.forEach(
      element => {
          if (element == false) {
              returnValue = element;
          }
      }
  );
  if (!returnValue) {
      return returnValue;
  }
  host = uri.host.replace("www.", "");
  url = url.trim();
  let urlTest2 = [
      url[0] !== '#',
      url.indexOf('tel:') == -1,
      url.indexOf('mailto:') == -1,
      url.indexOf('javascript:') == -1,
      url.indexOf('https://') == -1 || url.indexOf(host) !== -1,
      url.indexOf('http://') == -1 || url.indexOf(host) !== -1
  ];
  urlTest2.forEach(
      element => {
          if (element == false) {
              returnValue = element;
          }
      }
  );

  return returnValue;
}

function newUrl(uri, href) {
  href = href.trim();
  if (href.indexOf(uri.hostname) !== -1) {
      return href;
  }

  if (href.indexOf("..") !== -1 && href.split("..").length == 2) {
      let path = uri.pathname.substring(0, uri.pathname.lastIndexOf("/")) + href.replace("..", "");

      return uri.protocol + '//' + uri.hostname + path;
  }

  if (href[0] !== '/') {
      href = "/" + href;
  }

  return url = uri.protocol + '//' + uri.hostname + href;
}

router.get('/', async function (request, response, next) {
  let json = {}
  if (request.query['url'] === undefined) {
    json['error'] = 'Params url absent';
    res.json(json);
    return;
  }
  const crawler = new Crawler(
    {
      callback: (error, res, done) => {
        let json = {
          url: request.query.url
        };
        let links = [];
        if (error) {
          json = {
            'error': error
          };
        } else {
          let $ = cheerio.load(res.body);
          json['body'] = $('body').html();
          let titre = $("title").text();
          let a = $("a");
          a.each(
              (i, element) => {
                  let href = $(element).attr('href');
                  if (testUrl(res.request.uri, href)) {
                      let newurl = newUrl(res.request.uri, href);
                      if (links.indexOf(newurl) === -1) {
                          links.push(newurl);
                          links.sort();
                      }
                  }
              }
          )
          json['links'] = links;
        }
        response.json(json);
        done();
      }
    }
  )
  data = crawler.queue([request.query.url])
});

module.exports = router;