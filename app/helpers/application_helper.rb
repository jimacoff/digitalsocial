module ApplicationHelper

  def show_partners
    !current_user || @show_partners
  end

  def project_membership_nature_options
    Concepts::ProjectMembershipNature.top_level_concepts.collect { |pmn| [pmn.label, pmn.uri] }
  end

  def project_options
    Project.all.resources.collect { |p| [p.label, p.uri] }
  end

  def organisation_options
    Organisation.all.resources.collect { |o| [o.name, o.uri] }
  end

  def current_organisation_membership
    current_user.organisation_memberships.where(organisation_uri: current_organisation.uri.to_s).first
  end

  def build_organisation_breadcrumbs(active_index)
    list_content = []
    build_organisation_steps.each_with_index do |label, n|
      list_content.push(content_tag(:li, content_tag(:span, label), class: build_organisation_breadcrumb_class(n, active_index)))
    end

    content_tag :ol, list_content.join(" ").html_safe, class: "breadcrumbs"
  end

  def build_organisation_steps
    ["About you", "Org basics", "Org details", "1st project", "Project details", "Project invites", "Finish"]
  end

  def build_organisation_breadcrumb_class(n, active_index)
    if n < active_index
      "complete"
    elsif n == active_index
      "active"
    else
      "incomplete"
    end
  end

  def project_start_date_options(opts={})
    years_ago = opts[:years_ago] || 10

    options = []
    options += (Date.today.year-years_ago..Date.today.year).to_a.reverse.collect do |year|
      months = (1..12).to_a.reverse.collect do |n|
        label = [Date::MONTHNAMES[n], year].join(" ")
        date  = Date.parse(label)

        label if date < Date.today
      end.compact

      [year, months]
    end

    options
  end

  def project_end_date_options(opts={})
    years_ahead = opts[:years_ahead] || 10

    options = []
    options.push([nil, [["Ongoing", nil]]])

    options += (Date.today.year..Date.today.year+years_ahead).to_a.collect do |year|
      months = (1..12).to_a.collect do |n|
        label = [Date::MONTHNAMES[n], year].join(" ")
        date  = Date.parse(label)

        label if date > Date.today.year
      end.compact

      [year, months]
    end

    options
  end

  def asteroid_image_path
    "/assets/asteroids/#{rand(5)+1}_70x70.png"
  end

  def home_map_popup(organisation)
    content = []
    content.push "<h3>#{link_to organisation.name, organisation}</h3>"

    content.join
  end

  def notes_project_name(project)
    project.name.present? ? project.name : 'this project'
  end

  # Takes a User and titlecases their username
  #
  # Rails titlecase has odd behaviour i.e. it converts "RIck" into "R Ick"
  # so we downcase first.
  def titlecase_users_name(user)
    user.first_name.downcase.titlecase
  end

  def maybe_display_user_name_and_email(respondable, current_user)
    maybe_user_name = (respondable.invited_email.blank? || respondable.invited_email == current_user.email) ? 'you' : respondable.invited_user_name

    maybe_email = if respondable.invited_email.present?
                    ' (' + respondable.invited_email + ') '
                  else
                    ''
                  end
    "#{maybe_user_name} #{maybe_email}"
  end

  def maybe_display_provided_message_preamble project_invite
    if project_invite.personalised_message
      "They indicated that they worked with #{project_invite.invited_user_name} (#{project_invite.invited_email}) and provided the following message: "
    else
      ''
    end
  end

  def filter_section_header(criteria, opts={})
    label   = opts[:label] || criteria.to_s.humanize

    content = "<a href='#' class='title'><div class='expand-triangle'></div> <div class='collapse-triangle'></div>"
    if params[:filters].present? && params[:filters][criteria].present? && params[:filters][criteria].any?
      content += "<strong>#{label} (#{params[:filters][criteria].length})</strong></a>"
      content += "<a href='#' class='reset'>Reset</a>"
    else
      content += "#{label}</a>"
    end

    "<div class='filter-section-header'>#{content}</div>"
  end


  def filter_option(object, klass, opts={})
    object_label = object.send(opts[:label_method] || 'label')
    object_value = object.send(opts[:value_method] || 'uri')

    return nil if object_label == 'Other'

    checked = params[:filters].present? && params[:filters][klass.to_sym].present? && params[:filters][klass.to_sym].include?(object_value)

    checkbox = check_box_tag "filters[#{klass}][]", object_value, checked, id: "filter_#{klass}_#{object_label.parameterize('_')}"
    label    = label_tag "filter_#{klass}_#{object_label.parameterize('_')}", object_label

    content_tag :div, [checkbox, label].join(" ").html_safe, class: 'option'
  end

  def markdown(text)
    renderer = Redcarpet::Render::HTML.new({ hard_wrap: true })
    markdown = Redcarpet::Markdown.new(renderer, { autolink: true })

    markdown.render(text).html_safe
  end

  def admin_help_enabled?
    session[:admin_hide_help].nil?
  end

  # home panel helper
  def welcome_selected_class
    @selected_panel == 'welcome_panel' ? 'selected' : ''
  end

  # home panel helper
  def filter_selected_class
    @selected_panel == 'filter_panel' ? 'selected' : ''
  end

  def submenu_link text, url, hilight_when
    unless (hilight_when.nil?)
      css_class = hilight_when == @hilight_in_menu ? "hilight" : ""
    end
    link_to text, url, class: css_class
  end

  def parent_menu_link_hilight navigation
    navigation.hilight ? "hilight" : ""
  end

  def hilight_in_menu(str)
    @hilight_in_menu = str.downcase
  end

  def hilight_parent(str)
    @hilight_parent_menu_link = str.downcase
  end

  def community_menu
    content_for(:community_menu_highlighted, 'hilight')
    {:hilight => 'community',
     :items => [{
                 :title => 'Projects',
                 :target => projects_path,
                 :hilight => 'projects'
                },
                {
                 :title => 'Organisations',
                 :target => organisations_path,
                 :hilight => 'organisations'
                },
                {
                 :title => 'Events',
                 :target => '/events',
                 :hilight => 'events'
                }
                ]}
  end

  def resources_menu
    content_for(:resource_menu_highlighted, 'hilight')
    # TODO: fill in these agreed categories when the blog site is up
    {:hilight => 'resources',
     :items => [# {
                #  :title => 'Case Studies',
                #  :target => '#',
                #  :hilight => ''
                # },
                # {
                #  :title => 'Research',
                #  :target => '#',
                #  :hilight => ''
                # },
                {
                 :title => 'Linked Open Data',
                 :target => 'http://data.digitalsocial.eu/',
                 :hilight => 'data'
               },
               {
                 :title => 'Research',
                 :target => '/pages/research',
                 :hilight => 'research'
               },
               {
                 :title => 'Presentations',
                 :target => '/pages/presentations',
                 :hilight => 'presentations'
               },
               {
                 :title => 'Funding and Support',
                 :target => '/pages/funding-and-support',
                 :hilight => 'funding-and-support'
               }#,
              #  {
              #    :title => 'Resources',
              #    :target => '/pages/resources',
              #    :hilight => 'resources'
              #  }
                # ,{
                #  :title => 'Related work',
                #  :target => '#',
                #  :hilight => ''
                # }
               ]
    }
  end

  def sorted_org_and_proj_results(results)
    results.sort do |a, b|
      a_label = a.is_a?(Hash) ? a['name']['value'].upcase.gsub(/[^\s\w]/, '') : a
      b_label = b.is_a?(Hash) ? b['name']['value'].upcase.gsub(/[^\s\w]/, '') : b
      a_label <=> b_label
    end
  end

  def header_link_class(item)
    @active_header == item ? 'active' : nil
  end

end
