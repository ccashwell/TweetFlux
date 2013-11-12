class HomeController < ApplicationController
  include ActionController::Live

  before_filter :determine_hashtag

  def index
    @tweets = rest_client.search("#{@hashtag} -rt").to_a.reverse.map do |tweet|
      tweet_hash(tweet)
    end
  end

  def stream
    response.headers['Content-Type'] = 'text/event-stream'
    streaming_client.filter(track: @hashtag) do |tweet|
      response.stream.write(tweet_event(tweet)) unless tweet.retweeted?
    end
  rescue IOError
    # Client disconnected
  ensure
    response.stream.close
  end

  private

  def determine_hashtag
    @hashtag = "##{params[:hashtag].present? ? params[:hashtag] : 'redis'}"
  end

  def rest_client
    $twitter_rest_client
  end

  def streaming_client
    $twitter_streaming_client
  end

  def tweet_event tweet
    [ 'event: tweet', "data: #{JSON.dump(tweet_hash(tweet))}" ].join("\n") + "\n\n"
  end

  def tweet_hash tweet
    {
      content: tweet.full_text,
      timestamp: tweet.created_at,
      user: {
        avatar: tweet.user.profile_image_url.to_s,
        name: tweet.user.name,
        handle: tweet.user.screen_name,
        url: tweet.user.url.to_s
      }
    }
  end
end
