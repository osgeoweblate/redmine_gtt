module RedmineGtt
  module Patches

    module IssuePatch

      def self.apply
        unless Issue < self
          Issue.prepend self
          Issue.prepend GeojsonAttribute
          Issue.extend ClassMethods
          Issue.class_eval do
            attr_reader :distance
            safe_attributes "geojson",
              if: ->(issue, user){
                perm = issue.new_record? ? :add_issues : :edit_issues
                user.allowed_to? perm, issue.project
              }
            before_update :ignore_small_geom_change, if: :geom_changed?
          end
        end
      end

      def map
        json = as_geojson
        GttMap.new json: json, layers: project.gtt_tile_sources.sorted,
          bounds: (new_record? ? project.map.json : json)
      end

      # Check if geometry change aren't small and ignore it
      # (i.e. [140.1250590699026,35.6097256061325] vs [140.1250590699026,35.60972560613251])

      def ignore_small_geom_change
        unless geom_change[0].nil?
          if geom_change[0].as_json.fetch("type") == geom_change[1].as_json.fetch("type")
            old_value = geom_change[0].as_json.fetch("coordinates")
            new_value = geom_change[1].as_json.fetch("coordinates")
            self.geom = geom_change[0] if new_value.zip(old_value).map { |a, b| (a-b).abs }.map {|x| x < 0.00001}.all?
          end
        end
      end

      module ClassMethods
        def load_geojson(issues)
          if issues.any?
            geometries_by_id = Hash[
              Issue.
              where(id: issues.map(&:id)).
              pluck(:id, Arel.sql(Issue.geojson_attribute_select))
            ]
            issues.each do |issue|
              issue.instance_variable_set(
                "@geojson", Conversions.to_feature(geometries_by_id[issue.id])
              )
            end
          end
        end
      end

    end

  end
end

