<div class="container" markdown="1">
# Support Portal
Hello, <%= current_user['name'] %>!
<div class="row" markdown="1">

<div class="col-xs-12 col-sm-6" markdown="1">
## IT
* [Email](/it/email)
* bar
* foo
* bar
* foo
* bar
* foo
* bar
</div>

<div class="col-xs-12 col-sm-6" markdown="1">
## Production Engineering
* [DNS](/prodeng/dns)
* bar
* foo
* bar
* foo
* bar
</div>

</div>
<div class="row" markdown="1">

<div class="col-xs-12 col-sm-6" markdown="1">
## Project Management
* [JIRA](/pm/jira)
bar
</div>

<div class="col-xs-12 col-sm-6" markdown="1">
## Onboarding &amp; Offboarding
* [Onboarding](/boarding/onboarding)
* [Offboarding](/boarding/offboarding)
</div>

</div>

<%= button_to 'Logout', logout_path, :method => :delete %>
</div>
