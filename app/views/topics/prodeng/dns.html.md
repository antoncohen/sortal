<div class="container" markdown="1">
# DNS help!


<%= form_for :jira, url: {:controller=>'submit', action: 'jira'}, html: {class: 'jira_form'} do |f| %>
  Subject: <%= f.text_field :subject %>
  <br>
  Body: <%= f.text_area :body, size: '60x12' %>
  <%= f.submit 'Submit' %>
<% end %>
</div>
