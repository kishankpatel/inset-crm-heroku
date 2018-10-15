# Rails.application.config.middleware.use OmniAuth::Builder do
#   provider :google_oauth2, ENV['1036043446404-rot5smcu95l6gbavhv6md2toe3mg84l4.apps.googleusercontent.com'], ENV['yrYF4hGmWQercbtXMs_tAGxb'], {
#   scope: ['email',
#     'https://www.googleapis.com/auth/gmail.modify'],
#     access_type: 'offline'}
# end

#
# Google Details
# GOOGLE_CLIENT_ID = "1036043446404-rot5smcu95l6gbavhv6md2toe3mg84l4.apps.googleusercontent.com"#ENV['GOOGLE_CLIENT_ID'].freeze
# GOOGLE_CLIENT_SECRET = "yrYF4hGmWQercbtXMs_tAGxb" #ENV['GOOGLE_CLIENT_SECRET'].freeze
# #
# #
# # Google OAuth Builder
# Rails.application.config.middleware.use OmniAuth::Builder do
#   provider :google_oauth2, GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, {
#       scope: %w(https://mail.google.com/ plus.me userinfo.email),
#       access_type: 'offline',
#       prompt: 'consent',
#       name: 'google'
#   }
# end
# Google Details
# Google Details

begin 
OmniAuth.config.logger = Rails.logger
GOOGLE_CLIENT_ID = "1036043446404-rot5smcu95l6gbavhv6md2toe3mg84l4.apps.googleusercontent.com"#ENV['GOOGLE_CLIENT_ID'].freeze
GOOGLE_CLIENT_SECRET = "yrYF4hGmWQercbtXMs_tAGxb" #ENV['GOOGLE_CLIENT_SECRET'].freeze

GOOGLE_MAILBOX_CLIENT_ID = MAILBOX_CREDENTIALS["client_id"]
GOOGLE_MAILBOX_CLIENT_SECRET = MAILBOX_CREDENTIALS["client_secret"]
#
#
# Google OAuth Builder
# Rails.application.config.middleware.use OmniAuth::Builder do
#   provider :google_oauth2, GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, {
#       scope: %w(https://mail.google.com/ plus.me userinfo.email),
#       access_type: 'offline',
#       # prompt: 'consent',      
#       name: 'google_oauth2'
#   }
# end
# # Google OAuth Builder
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, GOOGLE_MAILBOX_CLIENT_ID, GOOGLE_MAILBOX_CLIENT_SECRET, {
      #scope: %w(https://mail.google.com/ plus.me userinfo.email ),
      scope: ['email','userinfo.email','calendar', 'https://www.googleapis.com/auth/gmail.modify'],
      access_type: 'offline',
      prompt: 'consent',
      name: 'google',
      provider_ignores_state: true,
      callback_path: '/auth/google/mailbox/callback'
  }
end

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :linkedin, "81x9py4honia9f", "P0d35zEzepx2eBN0"
end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}

rescue
end