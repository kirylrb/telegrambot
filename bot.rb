require 'dotenv/load'
require 'nokogiri'
require 'telegram/bot'
require 'open-uri'

token = ENV['TG_TOKEN']
$posts = []

# Parse method
def parse_posts
  url = 'http://bash.im/best'
  page = Nokogiri::HTML(open(url))
  page.css('.quote').css('.text').each do |a|
    post = a.text
    $posts.push(post)
  end
end

parse_posts

# Bot runner
Telegram::Bot::Client.run(token) do |bot|
  begin
    bot.listen do |message|
      case message.text
      when '/posts'
        bot.api.send_message(
      chat_id: message.chat.id,
        text:  "Hi, #{message.from.first_name}.\n
        Total posts: #{$posts.length.to_s}")
        bot.api.send_message(
         chat_id: message.chat.id,
         # don't get how to insert '/n' to this yet
         text: "#{$posts.first(10)}")

        # machinegun from posts:
        # $posts.length.times do |i|
        #   bot.api.send_message(
        #   chat_id: message.chat.id,
        #   text: "#{$posts[i]+"\n"}")
        #   break if i > 5
        # end
      when '/refresh'
        parse_posts
      when '/stop'

      when '/help'
        bot.api.send_message(
        chat_id: message.chat.id,
        text: "Avaialable commands: \n 
        /posts - to show posts from bash.im \n
        /refresh - get freshest posts \n
        /stop - stop recieving joke posts") 
      else
        bot.api.send_message(
        chat_id: message.chat.id,
        text: "Sorry, IDK what you want from me")
      end
    end
  rescue Telegram::Bot::Exceptions::ResponseError => e
    retry
  end
end