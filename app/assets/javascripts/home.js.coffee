paused = false
tweetQueue = []

addTweet = (tweet) ->
  template = $.tmpl 'templates/tweet', tweet
  tweetQueue.push(template)
  processQueue()

processQueue = ->
  while !paused and tweetQueue.length > 0
    tweet = tweetQueue.shift()
    $('time.timeago', tweet).timeago()
    $('.content',     tweet).tweetLinkify()
    tweet.prependTo('.tweets')

getHashtag = ->
  $('input.hashtag').val().replace /\W/g, ''

listenForHashtagChange = ->
  $('input.hashtag').on 'change', ->
    location.replace "?hashtag=#{getHashtag()}"

listenForPause = ->
  $('.pause').on 'click', ->
    paused = $('.pause').toggleClass('paused').hasClass('paused')
    processQueue()

watchHashtag = ->
  source = new EventSource("/home/stream?hashtag=#{getHashtag()}")
  source.addEventListener 'tweet', (e) ->
    addTweet $.parseJSON(e.data)

$ ->
  tweets = $('.tweets').data 'tweets'
  addTweet tweet for tweet in tweets

  listenForHashtagChange()
  listenForPause()
  watchHashtag()
