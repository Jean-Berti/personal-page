class SlackModalController < ApplicationController
  skip_before_action :verify_authenticity_token, :authenticate_user!


  def handle_slack_interaction
    @parsed_payload = JSON.parse(params['payload'])
    if @parsed_payload['type'] == "view_submission"
      reply_submission
    elsif @parsed_payload['type'] == "block_actions"
      @contact = Contact.find(contact_id)
      unless admin_reply_exist?
        open_modal
      else
        admin_exist
      end
    end
  end

  def reply_submission
    parsed_reply = @parsed_payload['view']['state']['values']['block_value']['action_value']['value']
    parsed_contact_id = @parsed_payload['view']['state']['values']['block_contact_id']['action_contact_id']['value']

    AdminReplyService.save_reply(parsed_contact_id, {text: parsed_reply}, request.base_url)
  end


  private

  def contact_id
    @parsed_payload['actions'].first['value']
  end

  def trigger_id
    @parsed_payload['trigger_id']
  end


  def open_modal
    Slack.configure do |config|
      config.token = Rails.application.credentials.slack[:token]
    end
    client = Slack::Web::Client.new

    client.views_open(
        {
            "trigger_id": trigger_id,
            "view": {
                "type": "modal",
                "title": {
                    "type": "plain_text",
                    "text": "My App",
                    "emoji": true
                },
                "submit": {
                    "type": "plain_text",
                    "text": "Submit",
                    "emoji": true
                },
                "close": {
                    "type": "plain_text",
                    "text": "Cancel",
                    "emoji": true
                },
                "blocks": [
                    {
                        "type": "section",
                        "text": {
                            "type": "plain_text",
                            "text": "This is a plain text section block.",
                            "emoji": true
                        }
                    },
                    {
                        "type": "input",
                        "block_id": "block_value",
                        "element": {
                            "action_id": "action_value",
                            "placeholder": {
                                "type": "plain_text",
                                "text": "coucou petite perruche",
                            },
                            "type": "plain_text_input",
                            "multiline": true
                        },
                        "label": {
                            "type": "plain_text",
                            "text": "Label",
                            "emoji": true
                        }
                    },
                    {
                        "type": "input",
                        "block_id": "block_contact_id",
                        "element": {
                            "action_id": "action_contact_id",
                            "initial_value": contact_id,
                            "type": "plain_text_input"
                        },
                        "label": {
                            "type": "plain_text",
                            "text": "Label",
                            "emoji": true
                        }
                    }
                ]
            }
        }
    )
  end

  def admin_exist
    Slack.configure do |config|
      config.token = Rails.application.credentials.slack[:token]
    end
    client = Slack::Web::Client.new

    client.chat_postMessage(
        channel: '#building-a-slack-api',

        "blocks": [
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": "you already responded to this message, check it <#{request.base_url}#{contact_path(@contact)}|here>"
                }
            }
        ],
        as_user: true)
  end

  def admin_reply_exist?
    @contact.admin_reply
  end
end

