# The Cin framework.
# Copyright (c) Sourav Datta, soura.jagat@gmail.com

http = require 'http'

cin = exports

cin.process_url = (url) ->
  # If the URL doesn't begin with '/', then add
  if url[0] != '/'
    url = '/' + url
  # If url ends with '/', remove it
  if url.lastIndexOf('/') == (url.length - 1)
    url = url.substring 0, (url.length - 1)
  url

cin.pageError = (res) ->
  res.writeHead 404, 'Content-Type': 'text/html'
  res.end '<b>404 - page not found</b>'

class HttpServer
  @instance: null
  
  @getOne: (port_num) ->
    if HttpServer.instance == null
      HttpServer.instance = new HttpServer port_num
    return HttpServer.instance
  
  page_map: {}
  
  constructor: (@port) ->
    @port = 8080 if not @port
    
  getter: (url, fn) ->
    @page_map[cin.process_url(url)] = fn
    
  run: ->
    @server = http.createServer()
    @server.on 'request', (req, res) =>
      res.writeHead 200, 'Content-Type': 'text/html'
      theUrl = cin.process_url req.url
      if @page_map[theUrl]
        res.end @page_map[theUrl]()
      else
        cin.pageError res
    @server.listen @port
    console.log 'Running on ', @port
    
cin.CinServer = HttpServer

cin.port = (port_num) ->
  HttpServer.getOne(port_num)
  
cin.get = (url, fn) ->
  server = HttpServer.getOne().getter(url, fn)
  
cin.start = -> HttpServer.getOne().run()
