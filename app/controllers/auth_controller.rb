class AuthController < ApplicationController
  include AuthHelper

  def gettoken
    p params[:code]
  token = get_token_from_code params[:code]
  #render text: "TOKEN: #{token.token}"
  @azure_token = token.to_hash

  # If a token is present in the session, get messages from the inbox
  # callback = Proc.new do |r| 
  #   r.headers['Authorization'] = "Bearer #{token}"
  # end
  # graph = MicrosoftGraph.new(base_url: 'https://graph.microsoft.com/v1.0',
                                 # cached_metadata_file: File.join(MicrosoftGraph::CACHED_METADATA_DIRECTORY, 'metadata_v1.0.xml'),
                                 # &callback)

  offmail = OfficeMail.where(:user_id=>@current_user.id,:organization_id=>@current_organization.id).first
  if !(offmail.present?)
    OfficeMail.create(:user_id=>@current_user.id,:organization_id=>@current_organization.id,token_hash:token.to_hash, token: token.token)
  end
  #session[:azure_token] = token.to_hash
  redirect_to office365_mails_url 
  end
end