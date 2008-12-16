require 'digest/sha1'
require 'opensteam'

class User < ActiveRecord::Base
  
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles

  include Opensteam::UserBase::UserLogic

  #include Opensteam::System::FilterEntry::Filter
  

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :firstname,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :firstname,     :maximum => 100

  validates_format_of       :lastname,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :lastname,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  attr_accessor :old_password
  attr_accessible :login, :email, :lastname, :firstname, :password, :password_confirmation, :old_password

  has_and_belongs_to_many :user_roles, :class_name => "UserRole"

  after_create :set_customer_role, :send_signup_notification
  after_save :send_create_activation

  named_scope :by_profile, lambda { |profile_name| { :include => :user_roles, :conditions => ["user_roles.name = ?", profile_name ] } }

  named_scope :role, lambda { |role| { :include => :user_roles, :conditions => ["user_roles.name = ?", role.downcase ] } }
  

  def send_signup_notification
    mail = Mailer::UserMailer.create_signup_notification( self )
    Mailer::UserMailer.deliver( mail )
  end

  def send_create_activation
    mail = Mailer::UserMailer.create_activation( self ) if self.recently_activated?
    Mailer::UserMailer.deliver( mail )
  end


  def has_specific_role?( role )
    @_list ||= self.user_roles.collect(&:name)
    @_list.include?( role.to_s )
  end

  def has_role?( role )
    return false unless self.active?
    @_list ||= self.user_roles.collect(&:name)
    @_list.include?( role.to_s ) || @_list.include?( "admin" )
  end
  
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_in_state :first, :active, :conditions => {:login => login} # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def name
    [ self.firstname, self.lastname ].join(" ")
  end

  #  def name=(value)
  #    write_attribute :firstname, ( value ? value : nil )
  #  end

  def profile=(profile)
    profile = UserRole.find_by_name( profile.to_s ) if ( profile.is_a?( String ) || profile.is_a?( Symbol ) )
    self.user_role_ids << profile.id if profile
  end


  def is_guest?
    self.has_specific_role?('guest')
  end
  

  def self.new_or_existing_guest( attr )
    attr.symbolize_keys!

    attr[:firstname] = "guest" unless attr[:firstname]
    attr[:lastname] = "guest" unless attr[:lastname]
    attr[:password] = attr[:password_confirmation] = 'opensteam'

    return( find_by_email( attr[:email] )  || new( attr ) )
    
  end

  protected
  
  def make_activation_code
    self.deleted_at = nil
    self.activation_code = self.class.make_token
  end

  def set_customer_role
    self.user_roles << UserRole.find_or_create_by_name( "customer" )
  end


end
