class ProjectsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :find_project, only: [:invite, :create_invite, :edit, :update]
  before_filter :set_project_invite, only: [:create_invite]
  before_filter :check_project_can_be_edited, only: [:edit, :update]

  def new
    @project = Project.new
    @project_request = ProjectRequest.new
  end

  def index
    #redirect_to [:new, :project] unless current_organisation.any_projects?
  end

  def create
    @project = Project.new

    if @project.update_attributes(params[:project])
      @project.create_time_interval!
      @project.add_creator_membership!(current_organisation)
      redirect_to :projects
    else
      render :new
    end
  end

  def invite
    @project_invite = ProjectInvite.new
  end

  def create_invite
    if @project_invite.save
      render text: "Invited organisation!"
    else
      render :invite
    end
  end

  def edit

  end

  def update
    if update_project
      redirect_to :projects, notice: "Project updated."
    else
      render :edit
    end
  end

  def create_request
    @project_request = ProjectRequest.new
    @project_request.attributes   = params[:project_request]
    @project_request.organisation = current_organisation

    if @project_request.save
      render text: "Requested to be part of project"
    else
      @project = Project.new
      render :new
    end
  end

  private

  def find_project
    @project = Project.find("http://example.com/project/#{params[:id]}")
  end

  def set_project_attributes
    params[:project].each { |k, v| @project.send("#{k}=", v) }
  end

  def set_project_invite
    @project_invite = ProjectInvite.new
    @project_invite.attributes   = params[:project_invite]
    @project_invite.project_uri  = @project.uri
  end

  def check_project_can_be_edited
    redirect_to :projects unless current_organisation.can_edit_project?(@project)
  end

  def update_project
    transaction = Tripod::Persistence::Transaction.new
    
    @duration = @project.duration_resource
    @duration.start_date = params[:project][:start_date]
    @duration.end_date   = params[:project][:end_date]

    if @project.update_attributes(params[:project], transaction: transaction) && @duration.save(transaction: transaction)
      transaction.commit
      true
    else
      transaction.abort
      false
    end
  end
  
end