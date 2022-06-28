class GttConfigurationController < ApplicationController

    accept_api_auth :default_setting_configuration

    def default_setting_configuration
        gtt_map_config = build_default_setting_config
        respond_to do |format|
          format.api { render json: build_default_setting_config}
        end
    end
      
    def build_default_setting_config
        default_tracker_icon = []
        default_status_color = []

        Tracker.all.sort.each {|tracker|
            default_tracker_icon.append({
                trackerID: tracker.id.to_s,
                trackerName: tracker.name,
                icon: Setting.plugin_redmine_gtt['tracker_'+tracker.id.to_s]
            })
        }
        IssueStatus.all.sort.each {|status|
            default_status_color.append({
                statusID: status.id.to_s,
                statusName: status.name,
                color: Setting.plugin_redmine_gtt['status_'+status.id.to_s]
            })
        }

        mapConfig = {
            defaultTrackerIcon: default_tracker_icon,
            defaultStatusColor: default_status_color,
            defaultMapSetting: {
                centerLng: Setting.plugin_redmine_gtt['default_map_center_longitude'],
                centerLat: Setting.plugin_redmine_gtt['default_map_center_latitude']
            },
            geometrySetting: {
                geometryTypes: Setting.plugin_redmine_gtt['editable_geometry_types_on_issue_map'],
                GeoJsonUpload: Setting.plugin_redmine_gtt['enable_geojson_upload_on_issue_map'],
            },
            geocoderSetting: {
                enableGeocodingOnMap: Setting.plugin_redmine_gtt['enable_geocoding_on_map'],
                geocoderOptions: Setting.plugin_redmine_gtt['default_geocoder_options']
            }
        }
        
        return mapConfig
    end
end