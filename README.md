# Sortal

A basic portal for submitting issues/tickets.

Uses Ruby on Rails.

## Development

1. Install Docker
2. `cp .docker-compose-env.sample .docker-compose-env` # Edit
3. `docker-compose build`
4. `docker-compose run web bundle install` # Updates Gemfile.lock
5. `docker-compose up`
6. Visit [127.0.0.1:3000](http://127.0.0.1:3000)

## SAML

To use SAML for authentication, set the environment variable `AUTH_PROVIDER=saml`.

### Okta

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
