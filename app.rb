require 'sinatra/base'
require 'onelogin/ruby-saml'
require 'json'
require 'pp'

class App < Sinatra::Base
  set :bind, "0.0.0.0"

  configure do
    set :cache_control, :no_store
    set :static_cache_control, :no_store
  end

  get "/" do
    "<p>The site is up!</p>"
  end

  get '/saml/authentication_request' do
    request = OneLogin::RubySaml::Authrequest.new
    redirect request.create(get_saml_settings)
  end

  post '/saml/consume' do
    response          = OneLogin::RubySaml::Response.new(params[:SAMLResponse])
    response.settings = get_saml_settings
    pp response.attributes

    if response.is_valid?
      "Success! Hello #{response.attributes['urn:oid:2.5.4.42']}!"
    else
      'Error'
    end
  end

  get '/saml/metadata' do
    meta = OneLogin::RubySaml::Metadata.new

    content_type 'text/xml'
    meta.generate(get_saml_settings, true)
  end

  def get_saml_settings
      idp_metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new
      settings = idp_metadata_parser.parse_remote("https://shibidp-test.cit.cornell.edu/idp/shibboleth")

      settings.assertion_consumer_service_url = "https://shib.srb55.cs.cucloud.net/saml/consume"
      settings.issuer                         = "https://shib.srb55.cs.cucloud.net/saml/metadata"
      settings.authn_context                  = "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"

      settings
    end

end
