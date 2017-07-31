require 'dotenv/load'
require 'nokogiri'
require 'telegram/bot'
require 'open-uri'
require 'logger'

TOKEN = ENV['TG_TOKEN'].freeze
URL = 'http://bash.im/best'.freeze
$posts = []

# Parse method
def parse_posts
  page = Nokogiri::HTML(open(URL))
  page.css('.quote').css('.text').each do |a|
    post = a.text
    $posts.push(post)
  end
end

parse_posts

# Bot runner
Telegram::Bot::Client.run(TOKEN) do |bot|
  begin
    bot.listen do |message|
      case message.text
      when '/posts'
        bot.api.send_message(
          chat_id: message.chat.id,
          text:  'Hi, #{message.from.first_name}.\n
          Total posts: #{$posts.length}'
        )
        bot.api.send_message(
          chat_id: message.chat.id,
          text: $posts.first(10).join('\n \n').to_s
        )
      when '/refresh'
        parse_posts
      # TODO: when '/stop'
      when '/help'
        bot.api.send_message(
          chat_id: message.chat.id,
          text: 'Avaialable commands: \n
          /posts - to show posts from bash.im \n
          /refresh - get freshest posts \n
          /stop - stop recieving joke posts'
        )
      else
        bot.api.send_message(
          chat_id: message.chat.id,
          text: 'Sorry, IDK what you want from me'
        )
      end
    end

  rescue Telegram::Bot::Exceptions::ResponseError => err
    logger = Logger.new('errors.log', 10, 1024000)
    logger.error err.message
    logger.error err.backtrace.join("\n")
  end
end
