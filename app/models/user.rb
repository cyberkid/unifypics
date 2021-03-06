require 'xmlsimple'

class User
  include Mongoid::Document
  has_many :photosets
  
  field :user
  field :fb_code
  field :fb_session
  field :flickr_oauth_token
  field :flickr_oauth_secret
  field :flickr_oauth_verifier
  field :created_at
  field :updated_at
  field :flickr_access_token
  field :flickr_access_secret
  field :flickr_username
  field :flickr_user_nsid
  field :fb_first_name
  field :fb_last_name
  field :google_access_token
  field :google_access_secret
  field :google_name
  field :google_userid

  def get_display_name
    display_name = ""
    display_name += self.fb_first_name + " " if self.fb_first_name
    display_name += self.fb_last_name if self.fb_last_name
    return display_name
  end
  
  def get_all_flickr_sets
    config = YAML.load_file(Rails.root.join("config/flickr.yml"))[Rails.env]
    FlickRaw.api_key = config['key']
    FlickRaw.shared_secret = config['secret']

    flickr = FlickRaw::Flickr.new
    flickr.access_token = self.flickr_access_token
    flickr.access_secret = self.flickr_access_secret
    sets = flickr.photosets.getList(:user_id => self.flickr_user_nsid)
    
    return sets
  end
  
  def get_all_picasa_albums
    config = YAML.load_file(Rails.root.join("config/picasa.yml"))[Rails.env]
        
    consumer = OAuth::Consumer.new( config['client_id'], config['client_secret'], {
      :site => "https://www.google.com", 
      :request_token_path => "/accounts/OAuthGetRequestToken", 
      :access_token_path => "/accounts/OAuthGetAccessToken", 
      :authorize_path=> "/accounts/OAuthAuthorizeToken"
    })
    
    access_token = OAuth::AccessToken.new(consumer, self.google_access_token, self.google_access_secret)
    album_data = access_token.get('https://picasaweb.google.com/data/feed/api/user/default?kind=album&access=all')
    album_parsed =  XmlSimple.xml_in album_data.body
    albums = album_parsed['entry']

    return albums
  end
  
  def get_picasa_album_info(album_id)
    config = YAML.load_file(Rails.root.join("config/picasa.yml"))[Rails.env]
        
    consumer = OAuth::Consumer.new( config['client_id'], config['client_secret'], {
      :site => "https://www.google.com", 
      :request_token_path => "/accounts/OAuthGetRequestToken", 
      :access_token_path => "/accounts/OAuthGetAccessToken", 
      :authorize_path=> "/accounts/OAuthAuthorizeToken"
    })
    
    access_token = OAuth::AccessToken.new(consumer, self.google_access_token, self.google_access_secret)
    album_data = access_token.get("https://picasaweb.google.com/data/feed/api/user/default/albumid/#{album_id}?imgmax=d")
    album_parsed =  XmlSimple.xml_in album_data.body

    return album_parsed
  end
  
end
