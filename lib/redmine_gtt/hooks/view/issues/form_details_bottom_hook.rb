module RedmineGtt
  module Hooks
    class ViewIssuesFormDetailsBottomHook < Redmine::Hook::ViewListener
      def view_issues_form_details_bottom(context={})
        return '' if context[:issue].nil? || context[:issue].project.nil?
        return '' unless User.current.allowed_to?(:view_issues, context[:issue].project)

        if context[:issue].new_record?
          return '' unless User.current.allowed_to?(:add_issues, context[:issue].project)
        else
          return '' unless User.current.allowed_to?(:edit_issues, context[:issue].project)
        end

        section = [];
        section << context[:form].hidden_field(:geom,
          :value => Issue.get_geojson(context[:issue]), :id => 'geom')

        section << tag(:div, :data => {
          :geom => Issue.get_geojson(context[:issue]),
          :bounds => Project.get_geojson(context[:project]),
          :edit => 'Point LineString Polygon'
        }, :id => 'olmap', :class => 'ol-map')

        return section.join("\n")
      end
    end
  end
end
