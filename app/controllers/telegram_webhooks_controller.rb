class TelegramWebhooksController < Telegram::Bot::UpdatesController
  I18n.locale = 'bot'

  # adding bot to a new group
  def my_chat_member(my_chat_member)
    if my_chat_member.dig('new_chat_member', 'status') == 'member'
      respond_with :message, text: t('chat_invite')

      Chat.create(id: my_chat_member.dig('chat', 'id'), title: my_chat_member.dig('chat', 'title'))
    end
    Chat.find(my_chat_member.dig('chat', 'id')).destroy if my_chat_member.dig('new_chat_member', 'status') == 'left'
  end

  # request to create issue
  def message(message)
    change_title(message) unless message['new_chat_title'].nil?
    return if message['text'].nil?
    return unless message['text'].start_with?("@#{Telegram.bot.username}")

    if message.dig('chat', 'type') == 'private'
      respond_with :message, text: t('private_mention')
      return
    end

    response = IssueCreator.call(message)
    reply_with :message, text: response[:message], parse_mode: 'Markdown'
  end

  def start!(*)
    reply_with :message, text: t('hello')
  end

  def help!(*)
    respond_with :message, text: t('help', botname: Telegram.bot.username), parse_mode: 'Markdown'
  end

  private

  def change_title(message)
    chat = Chat.find(message.dig('chat', 'id'))
    chat.update(title: message['new_chat_title'])
  end
end
