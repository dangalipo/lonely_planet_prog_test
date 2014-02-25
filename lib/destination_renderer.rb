class DestinationRenderer

  TEMPLATE = "templates/example.html"
  DESTINATION_NAME_PLACEHOLDER  = "{DESTINATION_NAME}"
  DESTINATION_NAV_PLACEHOLDER = "{DESTINATION_NAVGATION}"
  DESTINATION_CONTENT_PLACEHOLDER = "{DESTINATION_CONTENT}"

  def initialize(destination)
    self.destination = destination
    self.template = File.read(File.join(File.expand_path(File.dirname(__FILE__)),TEMPLATE))
  end

  def render
    insert_destination_name
    insert_naviagation
    insert_destination_content
    template
  end

private

  attr_accessor :destination, :template

  def insert_destination_name
    template.gsub!(/#{DESTINATION_NAME_PLACEHOLDER}/, destination.name)
  end

  def insert_naviagation
    navigation_content = []
    navigation_content << generate_navigation_content("Parent Regions", destination.ancestors.reverse)
    navigation_content << generate_navigation_content("Sub Regions", destination.children)
    template.gsub!(/#{DESTINATION_NAV_PLACEHOLDER}/, navigation_content.compact.join("\n"))
  end

  def insert_destination_content
    destination_content = destination.content.collect{ |content| generate_destination_content(content, 1) }
    template.gsub!(/#{DESTINATION_CONTENT_PLACEHOLDER}/, destination_content.compact.join("\n"))
  end

  def generate_navigation_content(title, navigation_tree)
    if navigation_tree.empty?
      navigation_content = nil
    else
      navigation_elements = []
      navigation_elements << "<h4>#{title}</h4>"
      navigation_elements << "<ul>"
      navigation_tree.each do |navigation_item|
        navigation_elements << navigation_link(navigation_item)
      end
      navigation_elements << "</ul>"
      navigation_content = navigation_elements.join("\n")
    end
    navigation_content
  end

  def generate_destination_content(destination_content, level)
    generated_content = []
    generated_content << "<h#{level}>#{destination_content.title}</h#{level}>"
    generated_content << destination_content.content.collect{ |content| "<p>#{content}</p>" }.join("\n") unless destination_content.content.empty?
    destination_content.children.each do |child_content|
      generated_content << generate_destination_content(child_content, (level + 1))
    end
    generated_content.join("\n")
  end

  def navigation_link(navigation_destination)
    "<li><a href=\"#{navigation_destination.id}.html\">#{navigation_destination.name}</a></li>"
  end

end