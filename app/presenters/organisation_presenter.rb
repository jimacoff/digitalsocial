class OrganisationPresenter

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend  ActiveModel::Naming
  include ActiveModel::MassAssignmentSecurity

  attr_accessor :name, :organisation, :user, :organisation_membership, :site, :address,
    :lat, :lng, :street_address, :locality, :region, :country, :postal_code # location related fields

  attr_accessible :name, :lat, :lng, :street_address, :locality, :region, :country, :postal_code

  validates :name, :lat, :lng,  :street_address, :locality, :country, presence: true
  validate :organisation_name_is_unique

  def initialize(org=nil)
    if org.present?
      self.organisation   = org
      self.name           = org.name

      if (existing_site = org.primary_site_resource).present?
        existing_address = org.primary_site_resource.address_resource

        self.site           = existing_site
        self.address        = existing_address

        self.lat            = existing_site.lat
        self.lng            = existing_site.lng
        self.street_address = existing_address.street_address
        self.locality       = existing_address.locality
        self.region         = existing_address.region
        self.country        = existing_address.country
        self.postal_code    = existing_address.postal_code
      end
    end
  end

  def attributes=(values)
    sanitize_for_mass_assignment(values).each do |attr, value|
      public_send("#{attr}=", value)
    end
  end

  def site
    @site ||= Site.new
    @site.lat = self.lat
    @site.lng = self.lng
    @site.address = self.address.uri
    @site
  end

  def address
    @address ||= Address.new
    @address.street_address = self.street_address.strip
    @address.locality = self.locality.strip
    @address.region = self.region.strip
    @address.country = self.country
    @address.postal_code = self.postal_code.strip

    @address
  end

  def organisation
    @organisation ||= Organisation.new
    @organisation.name         = self.name.strip
    @organisation.primary_site = self.site.uri
    @organisation
  end

  def organisation_membership
    @organisation_membership ||= OrganisationMembership.new do |om|
      om.user             = self.user
      om.organisation_uri = self.organisation.uri.to_s
      om.owner            = true
    end
  end

  def save
    return false if invalid?

    transaction = Tripod::Persistence::Transaction.new

    if (self.address.save(transaction: transaction) &&
      self.site.save(transaction: transaction) &&
      self.organisation.save(transaction: transaction)
    )
      transaction.commit
      self.organisation_membership.save
    else
      transaction.abort
      return false
    end

    true
  rescue => e
    Rails.logger.debug e
    false
  end

  def organisation_guid
    self.organisation.guid
  end

  def persisted?
    false
  end

  private

  def organisation_name_is_unique
    name_predicate = Organisation.fields[:name].predicate.to_s
    if Organisation.where("?uri <#{name_predicate}> \"\"\"#{name}\"\"\"").where("FILTER(?uri != <#{organisation.uri}>)").count > 0
      errors.add(:name, "Organisation already exists")
    end
  end

end