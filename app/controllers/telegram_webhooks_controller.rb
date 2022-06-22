class TelegramWebhooksController < Telegram::Bot::UpdatesController
  
  # TODO: отклик на команду по упоминанию бота в группе
  def new!(*)
    header, body = parse_header_and_body(payload['text'])

    options = {
      username:     Rails.application.credentials.dig(:jira, :username),
      password:     Rails.application.credentials.dig(:jira, :api_token),
      site:         Rails.application.credentials.dig(:jira, :site),
      context_path: '',
      auth_type:    :basic
    }
    client = JIRA::Client.new(options)

    issue = client.Issue.build
    issue.save(
      {
        'fields' => {
          'summary'     => header,
          'project'     => { 'key' => 'GEGE' },
          'description' => body,
          'issuetype'   => { 'name' => 'Task' }
        }
      }
    )

    response = "Создана задача с номером [#{issue.key}](#{client.request_client.options[:site]}browse/#{issue.key})"
    reply_with :message, text: response, parse_mode: "Markdown"
  end

  def start!(*)
    reply_with :message, text: 'Hello'
  end

  private

  def parse_header_and_body(message)
    body = message.partition("\n\n")[2]
    header = message.partition("\n\n")[0].partition(' ')[2]
    [header, body]
  end
end
