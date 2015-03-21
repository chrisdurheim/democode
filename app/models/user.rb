class User < ActiveRecord::Base
  belongs_to :organization, inverse_of: :users
  accepts_nested_attributes_for :organization
  validates_associated :organization
  validates_presence_of :organization

  validates :name, presence: true
  validates :role, presence: true, inclusion: { in: %w(ADMIN USER)}

  before_validation :set_default_role

  scope :from_organization, ->(id) { where("organization_id = ?", id).order(role: :asc, email: :asc) }

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def admin?
    return self.role == "ADMIN"
  end

  def is_same_user_as?(other_user_id)
    return self.id == other_user_id.to_i
  end

  def in_same_organization?(other_user_id)
    @user = User.find_by_id(other_user_id)
    if @user.nil?
     return false
    else
     return (self.organization_id == @user.organization_id)
    end
  end

  def self.valid_roles
    return %w{ADMIN USER}
  end

  private
  def set_default_role
    self.role ||= "USER"
  end

end
