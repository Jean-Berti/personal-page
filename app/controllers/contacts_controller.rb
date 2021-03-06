require 'slack-ruby-client'

class ContactsController < ApplicationController


  def index
    @contacts = Contact.all
  end

  def show
    @contact = Contact.find(params[:id])
  end

  def new
    @contact = Contact.new
  end

  def edit
    @contact = Contact.find(params[:id])

  end

  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      ContactMailer.with(contact: @contact).contact_email.deliver_now
      send_notif_slack

      redirect_to @contact, notice: "contact #{@contact.name} has been created"
    else
      render 'new'
    end
  end

  def update
    @contact = Contact.find(params[:id])

    if @contact.update(contact_params)
      redirect_to @contact, notice: "New contact: #{@contact.name} has been updated successfully"
    else
      render 'edit'
    end
  end

  def destroy
    Contact.find(params[:id]).destroy
    redirect_to contacts_path, notice: "Your contact has been deleted"
  end


  private


  def send_notif_slack
    Slack.configure do |config|
      config.token = Rails.application.credentials.slack[:token]
    end
    client = Slack::Web::Client.new

    client.chat_postMessage(
        channel: '#building-a-slack-api',

        "blocks": [
            {
                "type": "divider"
            },
            {
                "type": "header",
                "text": {
                    "type": "plain_text",
                    "text": @contact.name,
                    "emoji": true
                }
            },
            {
                "type": "divider"
            },
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": "*#{@contact.subject}*"
                }
            },
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": @contact.message
                }
            },
            {
                "type": "actions",
                "elements": [
                    {
                        "type": "button",
                        "text": {
                            "type": "plain_text",
                            "text": "reply in slack",
                            "emoji": true
                        },
                        "value": "#{@contact.id}"
                    },
                    {
                        "type": "button",
                        "url": "#{request.base_url}#{contact_path(@contact)}",
                        "text": {
                            "type": "plain_text",
                            "text": "reply in my app",
                            "emoji": true
                        },
                        "value": "click_me_message"
                    },
                ],
            },
            {
                "type": "divider"
            },
        ],
        as_user: true)
  end


  def contact_params
    params.require(:contact).permit(:name, :email, :subject, :message)
  end
end
