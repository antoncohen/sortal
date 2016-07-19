class SubmitMailer < ApplicationMailer
  def email(message)
    @from_address = message.from_address
    @from_name = message.from_name
    @body_html = message.body_html
    @body_text = message.body_text

    mail(
      to: message.to,
      from: message.from,
      reply_to: message.reply_to,
      subject: message.subject
    )
  end
end
