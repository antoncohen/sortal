# Sortal

A basic portal for submitting issues/tickets.

Uses Ruby on Rails.

## Content changes

Adding or editing content (called *topics*) is super easy. All the topics are just markdown files in `app/views/topics/<section>/`. Simply create with a `.md` extension.

To add the topic to the home page just edit the index file in `app/views/home/` (also in markdown!).

### Markdown

The markdown used is [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/#GitHub-flavored-markdown). Specifically that means it supports hard line break, code fencing with language, and `~~` for strikethroughs.

You can use raw HTML in the markdown files. Inline elements, like `<b>` work interspersed with markdown. To use block elements like `<div>` you need to add the attribute `markdown="1"` to the opening tag in oder to have the inner text parsed as markdown. For example:

```html
<div markdown="1">
# This will be converted to an HTML <h1>
</div>

<div>
# This will be normal text, not parsed at markdown
</div>
```

The markdown converter used is [Kramdown](https://github.com/gettalong/kramdown), which required XHTML. The means you should close your HTML tags, so `<br>` should be `<br />`.

### ERB

The markdown views also support ERB! :grinning: The `.md` files are processed as ERB templates prior to going through the markdown converter.

### Forms

Forms for submitting issues and emails are added with ERB. The existing form templates live in `app/views/forms/`. The forms expect variables to be set to control specifics about the form.

Add the form ERB to the bottom of your markdown file.

**JIRA example:**

```erb
# Topic title

Topic text goes here.

<% @jira_project = 'EXMP' %>
<% @jira_type = 'Story' %>
<%= render template: 'forms/jira_default' %>
```

**Email example:**

```erb
# Topic title

Topic text goes here.

<% @email_to = 'help@example.com' %>
<%= render template: 'forms/email_default' %>
```

The form input is validated against allowed choices. These choices are set in environment variables as comma separated lists.

```shell
VALID_JIRA_ISSUE_TYPES=Task,Story,Bug
VALID_JIRA_PROJECTS=TST,EXMP
VALID_EMAIL_TO=help@example.com,support@example.com
```

## Local development environment

Local development takes place entirely in Docker. There is no need to install any dependancies on your local computer.

1. Install [Docker](https://www.docker.com/products/docker), on macOS get **Docker for Mac**
2. Run `cp .docker-compose-env.sample .docker-compose-env` and edit the new file
3. Run `docker-compose build` to build a base image
4. Start your server with `docker-compose up`
5. Visit [127.0.0.1:3000](http://127.0.0.1:3000)
6. Hit **Ctrl-C** and run `docker-compose down` when you are done

## Development

The bulk of the code lives in `lib/sortal/`, with additional code in `app/controllers/` and `config/initializers/`.

Code changes in `app/` should be reflected immediately in your development application, just refresh your browser. If you make changes elsewhere, like `lib/` you will need to to **Ctrl-C** the running server and  run `docker-compose up` to restart the application.

### Gem updates

Installing or updating Ruby gems works a little differently than other code changes, because the gems are installed in the base Docker image, and not in the source tree.

1. `docker-compose down` to stop your container
2. Update the **Gemfile**
3. Run `docker-compose build` to build a new base container
4. Run `docker-compose run --rm web bundle install` to update **Gemfile.lock**
5. `docker-compose up` to start the container with the new gems

## Testing

Run tests within Docker.

- `docker-compose run --rm web rake test`

## Authentication

Three authentication providers are supported:

- `google_oauth2` # the default and easiest to use
- `saml` # for enterprise auth
- `developer` # special provider that allows any name and email address, only in development mode

Set the provider using the `AUTH_PROVIDER` environment variable.

### Google

Get a client ID and secret by creating an app using the [Google API Console](https://console.developers.google.com/), then [generate credentials](https://console.developers.google.com/apis/credentials). Set the environment variables `GOOGLE_CLIENT_ID` and `GOOGLE_CLIENT_SECRET`.

See Google's [OpenID Connect documentation](https://developers.google.com/identity/protocols/OpenIDConnect) for full instructions.


### SAML

To use SAML for authentication, set the environment variable `AUTH_PROVIDER=saml`.

SAML setup will vary by provider.

#### Okta

SAML is confusing, here are instructions to configure an Okta app with the correct settings.

1. Create the app using the `SAML 2.0` wizard
2. **Single sign on URL:** `<your url>/auth/saml/callback`, this is where Okta will redirect back to after authentication
3. Check **Use this for Recipient URL and Destination URL**
4. **Audience URI:** Has to match the `SAML_ISSUER` environment variable, a good choice is your Okta URL, e.g., `https://<your org>.okta.com`
5. **Name ID format:** `EmailAddress`
6. **Application username:** `Email`
7. In **ATTRIBUTE STATEMENTS** add the following (Name, Name format, Value):
  - `email`, Unspecified, `user.email`
  - `first_name`, Unspecified, `user.firstName`
  - `last_name`, Unspecified, `user.lastName`

Once the app is created, click **View Setup Instructions** on the **Sign On** tab.

**Environment variables:**

- **SAML_REDIRECT_URL:** `<your url>/auth/saml/callback`, e.g., `https://www.example.com/auth/saml/callback`
- **SAML_ISSUER:** Whatever you set for *Audience URI* above
- **SAML_SIGNIN_URL:** *Identity Provider Single Sign-On URL* from the *Setup Instructions* page
- **SAML_FINGERPRINT:** Download the *X.509 Certificate* from the *Setup Instructions*, and run `openssl x509 -noout -fingerprint -in okta.cert`
- **SAML_NAME_FORMAT:** Can be left as default, should be `urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress`
