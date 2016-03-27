###
 CutThai is Thai language word segmentation written in coffeescript
 more information see https://github.com/pureexe/cutthai
###

class CutThai
  data:
    isInit: false
    trie: {}
    dictList: [
      "data/tdict-acronyms.txt",
      "data/tdict-city.txt",
      "data/tdict-collection.txt",
      "data/tdict-common.txt",
      "data/tdict-country.txt",
      "data/tdict-district.txt",
      "data/tdict-geo.txt",
      "data/tdict-history.txt",
      "data/tdict-ict.txt",
      "data/tdict-lang-ethnic.txt",
      "data/tdict-proper.txt",
      "data/tdict-science.txt",
      "data/tdict-spell.txt",
      "data/tdict-std-compound.txt",
      "data/tdict-std.txt"
    ]

  constructor: (dict,callback)->
    self = @
    if typeof dict is "function"
      callback = dict
    else
      if dict instanceof Array
        self.dictList = dict
      else
        self.dictList = [dict]
    if !callback
      callback = ->
    self.loadDict (err,wordlist)->
      if(err)
        callback(err)
      self.data.trie = self.buildTrie(wordlist)
      self.data.isInit = true
      callback()

  ##
  # load dictionary files
  loadDict: (callback)->
    cnt = 0
    dictLength = @data.dictList.length
    output = []
    if typeof(window) is "undefined" and typeof(module) is "object"
      readFile = @readFileNodeJS
    else
      readFile = @readFileBrowser
    for dict in @data.dictList
      readFile dict,(err,data)->
        if err
          callback(err)
        else
          data = data.toString().split("\n");
          output = output.concat(data)
          cnt++
          if cnt == dictLength
            callback(undefined,output)

  ##
  # Build Trie
  # Trie will use object not array because stackoverflow is confirm
  # that javascript object is hash (must same speed as array but easy to handle)
  # @param {Array} wordlist - array of string from dictionarry
  # @return {Object} Trie
  # @see https://en.wikipedia.org/wiki/Trie
  buildTrie: (wordlist)->
    trie = {}
    for word in wordlist
      i = 0
      ptr = trie
      while i < word.length
        if !ptr[word[i]]
          ptr[word[i]] = {}
        ptr = ptr[word[i]]
        i++
        if i == word.length
          ptr.word = true
    return trie;

  ##
  # Cut word into out
  # @param {string} sentense - to segmentation
  # @return {string} sentense with thai segmentation seperate with |
  cut: (sentense)->
    return @cutArray(sentense).join("|")

  ##
  # cut into array
  # @param {string} sentense - to segmentation
  # @return {array} sentense with thai segmentation to string of array
  cutArray: (sentense)->
    if !@data.isInit
      throw """Please wait constructor complete before call this method.
      it need little time build trie for increase speed of word segmentation"""
    else
      wordgraph = @createWordGraph(sentense)
      path = @findShortestPath(wordgraph)
      result = @splitByPath(sentense,path)
      return result

  ##
  # Create word graph from sentense by compare with trie
  # @params {string} sentense - input
  # @return {array} wordgraph
  createWordGraph: (sentense)->
    graph = []
    i = 0
    while i<sentense.length
      isEng = /^[A-Za-z][A-Za-z0-9]*$/
      graph[i] = {index:i,next:[]}
      trie = @data.trie
      j = 0
      if isEng.test(sentense[i]) ## english segment by using space
        while isEng.test(sentense[i+j]) and i+j<sentense.length
          j++
        graph[i].next.push(i+j)
      else ## thai sengment by using trie
        while trie
          if(trie.word)
            graph[i].next.push(i+j)
          else if(i+j+1==sentense.length)
            graph[i].next.push(i+j+1)
          trie = trie[sentense[i+j]]
          j++
        if graph[i].next.length == 0
          graph[i].next.push(i+1)
      i++
    graph[i] = {index:i,next:[],finish:true}
    return graph

  ##
  # find shortest word graph using SPFA
  # @params {array} graph - wordgraph from createWordGraph
  # @return {array} shortest path of wordgraph
  # @see https://en.wikipedia.org/wiki/Shortest_Path_Faster_Algorithm
  findShortestPath: (graph)->
    out = []
    queue = []
    visited = {}
    graph[0].dist = 0
    queue.push(0)
    while queue.length > 0
      u = queue.shift()
      for v in graph[u].next
        if !graph[v].dist or graph[u].dist + 1 < graph[v].dist
          graph[v].prev = graph[u]
          graph[v].dist = graph[u].dist+1
          if !visited[v]
            if queue.lenght > 0 and graph[queue[0]].dist > graph[v].dist
              queue.unshift(v)
            else
              queue.push(v)
            visited[v] = true
    index = graph.length-1
    while index !=0
      out.unshift(index)
      index = graph[index].prev.index
    return out

  ##
  # Split sentense to text from path
  # @params {string} sentense - input
  # @params {array} path - shortest path  from findShortestPath
  # @return word segmentation array
  splitByPath: (sentense,path)->
    console.log(path)
    path.unshift(0)
    out = []
    i=1
    prebuilt = ""
    while i<path.length
      cWord=sentense.substring(path[i],path[i-1])
      if path[i]-path[i-1] == 1
        if cWord !=" "
          prebuilt+=cWord
        else if prebuilt != ""
          out.push(prebuilt)
          prebuilt =""
      else
        if prebuilt!=""
          if out.length == 0
            out.push(prebuilt)
          else
            out[out.length-1]+=prebuilt
            prebuilt=""
        out.push(cWord)
      i++
    if prebuilt != ""
      out.push prebuilt
    return out

  ##
  #  support readFile from nodeJs
  #
  readFileNodeJS: (file,callback)->
    fs = require "fs"
    fs.readFile(file,callback)

  ##
  # support readFile from browser
  #
  readFileBrowser: (file,callback)->
    fileRequest = new XMLHttpRequest()
    fileRequest.onreadystatechange = ()->
      if fileRequest.readyState == 4 and fileRequest.status == 200
        callback(undefined,fileRequest.responseText)
      else if fileRequest.readyState == 4
        callback({message:"ENOENT: no such file or directory, open '#{file}' "})
    fileRequest.open("GET", file, true)
    fileRequest.send()

##
# Export module to support most platform of javascript
if typeof module == "object" and module and typeof module.exports == "object"
  module.exports = CutThai #support Node.js / IO.js / CommonJS
else
  window.CutThai = CutThai #support browser
  if typeof define == "function" && define.amd
    define 'CutThai', [], -> #support AMDjs
      CutThai
