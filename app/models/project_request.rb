class ProjectRequest

  include Mongoid::Document

  field :requestor_organisation_uri, type: String
  field :project_uri, type: String
  field :open, type: Boolean, default: true
  field :accepted, type: Boolean # nil until decision made.

  def project_resource
    Project.find(self.project_uri)
  end

  def requestor_organisation_resource
    Project.find(self.requestor_organisation_uri)
  end

  def accept!
    # todo
  end

  def reject!
   # todo
  end

  private

  def set_accepted
    self.open = false
    self.accepted = true
  end

  def set_rejected
    self.open = false
    self.accepted = false
  end

end