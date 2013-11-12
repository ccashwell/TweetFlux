require 'spec_helper'

feature 'Streaming Tweets' do
  scenario 'When using the default hashtag', js: true do
    visit root_path
    find('input.hashtag').value.should eq '#redis'

    page.should have_content 'Example User example_code'
    page.should have_content 'i need more #redis in my life'
    page.should have_css "a[href='https://twitter.com/search/?src=hash&q=%23redis']"

    page.should have_content 'chyld medford chyldmedford'
    page.should have_content 'My students @NashSoftware learned authentication and authorization using #redis, #nodejs, #mongodb, #mongoose and #expressjs.'
    page.should have_css "a[href='http://twitter.com/NashSoftware']"
  end

  scenario 'When using a custom hashtag', js: true do
    visit '/?hashtag=custom'
    find('input.hashtag').value.should eq '#custom'

    page.should have_content 'Ibn Anderson TheArtrepreneur'
    page.should have_content '#theartrepreneur bottom half of my lay today. @coachgaines #custom #chinos. #repaired #patched… http://t.co/gLSvwPCfwG'
    page.should have_css "a[href='http://t.co/gLSvwPCfwG']"

    page.should have_content 'Brittany Thomas brittan72737604'
    page.should have_content '#Fender #Custom Shop #1962 #Jaguar #NOS, surf green with matching headstock. #vintageandrare #vintag http://t.co/SNCBDgo8CE'
    page.should have_css "a[href='https://twitter.com/search/?src=hash&q=%23Jaguar']"
  end

  scenario 'Changing the hashtag', js: true do
    visit root_path
    field = find('input.hashtag')
    field.value.should eq '#redis'
    field.set "#custom\n"
    current_url.should eq 'http://127.0.0.1:31337/?hashtag=custom'
  end
end
