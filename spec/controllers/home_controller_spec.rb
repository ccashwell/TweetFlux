require 'spec_helper'

describe HomeController do
  let(:user) do
    double(:user,
           profile_image_url: URI('http://twitter.com/example_user/image.png'),
           name: 'Example User',
           screen_name: 'example_user',
           url: URI('http://twitter.com/example_user')
          )
  end

  let(:tweet_1) do
    double(:tweet_1,
           created_at: '2013-11-11 14:01:44 -0500',
           full_text: 'This is an #example tweet',
           retweeted?: false,
           user: user
          )
  end

  let(:tweet_2) do
    double(:tweet_2,
           created_at: '2013-11-12 14:01:44 -0500',
           full_text: 'This is another #example tweet',
           retweeted?: true,
           user: user
          )
  end

  let(:tweets) { [ tweet_1, tweet_2 ] }
  let(:rest_client) { double(:rest_client, search: tweets) }
  let(:streaming_client) { double(:streaming_client).as_null_object }
  let(:hashtag) { 'example' }

  describe '#index' do
    subject { get :index, hashtag: hashtag }
    before { controller.stub(:rest_client).and_return(rest_client) }

    it 'assigns the tweets instance variable' do
      subject
      assigns(:tweets).should eq [
        {
          content: 'This is another #example tweet',
          timestamp: '2013-11-12 14:01:44 -0500',
          user: {
            avatar: 'http://twitter.com/example_user/image.png',
            name: 'Example User',
            handle: 'example_user',
            url: 'http://twitter.com/example_user'
          }
        },
        {
          content: 'This is an #example tweet',
          timestamp: '2013-11-11 14:01:44 -0500',
          user: {
            avatar: 'http://twitter.com/example_user/image.png',
            name: 'Example User',
            handle: 'example_user',
            url: 'http://twitter.com/example_user'
          }
        }
      ]
    end

    context 'when a hashtag is provided' do
      it 'searches for the provided hashtag' do
        rest_client.should_receive(:search).with('#example -rt')
        subject
      end
    end

    context 'when no hashtag is provided' do
      let(:hashtag) { nil }
      it 'infers the default #redis hashtag' do
        rest_client.should_receive(:search).with('#redis -rt')
        subject
      end
    end
  end

  describe '#stream' do
    subject { get :stream, hashtag: hashtag }

    before { controller.stub(:streaming_client).and_return(streaming_client) }

    it 'sets the event-stream content type' do
      subject
      response.headers['Content-Type'].should eq 'text/event-stream'
    end

    context 'when an original tweet is returned' do
      before { streaming_client.stub(:filter).and_yield(tweet_1) }

      it 'streams the tweet to the client' do
        ActionDispatch::Response::Buffer.any_instance
          .should_receive(:write)
          .with("event: tweet\ndata: {\"content\":\"This is an #example tweet\",\"timestamp\":\"2013-11-11 14:01:44 -0500\",\"user\":{\"avatar\":\"http://twitter.com/example_user/image.png\",\"name\":\"Example User\",\"handle\":\"example_user\",\"url\":\"http://twitter.com/example_user\"}}\n\n")
        subject
      end
    end

    context 'when a retweeted tweet is returned' do
      before { streaming_client.stub(:filter).and_yield(tweet_2) }

      it 'does not stream the tweet' do
        ActionDispatch::Response::Buffer.any_instance.should_not_receive(:write)
        subject
      end
    end
  end
end
